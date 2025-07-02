// SPDX-License-Identifier: MIT
pragma solidity ^0.8.1;

import "./SalesUtils.sol";

contract CourseCommerceManager {
    using SalesUtils for SalesUtils.Product[];
    using SalesUtils for SalesUtils.Sale[];

    address public owner;

    struct Product {
        address productAddress;
        string name;
        uint256 price;
    }

    struct Sale {
        uint256 productId;
        uint256 purchaseDate;
        address buyer;
    }

    Product[] public products;
    Sale[] public sales;
    uint256 public totalSales;

    // Eventi
    event SaleAdded(uint256 indexed saleId, uint256 indexed productId, address indexed buyer, uint256 purchaseDate);
    event ProductAdded(uint256 indexed productId, string name, uint256 price);
    event FundsWithdrawn(address indexed owner, uint256 amount);

    // Modificatori
    modifier onlyOwner() {
        require(msg.sender == owner, "Unauthorized");
        _;
    }

    modifier productExists(uint256 _productId) {
        require(_productId < products.length, "Product does not exist");
        _;
    }

    modifier saleExists(uint256 _saleId) {
        require(_saleId < sales.length, "Sale does not exist");
        _;
    }

    constructor() {
        owner = msg.sender;
        totalSales = 0;
    }

    function withdrawFunds(uint256 _amount) external onlyOwner {
        require(_amount <= address(this).balance, "Insufficient Balance");
        require(_amount > 0, "Invalid Amount");
        payable(owner).transfer(_amount);
        emit FundsWithdrawn(owner, _amount);
    }

    function withdrawAllFunds() external onlyOwner {
        uint256 balance = address(this).balance;
        require(balance > 0, "No funds to withdraw");
        payable(owner).transfer(balance);
        emit FundsWithdrawn(owner, balance);
    }

    function addProduct(
        string memory _name,
        address _productAddress,
        uint256 _priceInEther
    ) external onlyOwner {
        require(_priceInEther > 0, "Invalid Price");
        require(bytes(_name).length > 0, "Invalid Name");
        uint256 priceInWei = _priceInEther * 1 ether;

        products.push(Product({
            productAddress: _productAddress,
            name: _name,
            price: priceInWei
        }));

        emit ProductAdded(products.length - 1, _name, priceInWei);
    }

     function getAllProducts()
        external
        view
        returns (address[] memory productAddresses, string[] memory names, uint256[] memory prices)
    {
        uint256 count = products.length;
        productAddresses = new address[](count);
        names = new string[](count);
        prices = new uint256[](count);

        for (uint256 i = 0; i < count; i++) {
            Product memory product = products[i];
            productAddresses[i] = product.productAddress;
            names[i] = product.name;
            prices[i] = product.price;
        }
    }

    function getProduct(uint256 _productId)
        external
        view
        productExists(_productId)
        returns (address productAddress, string memory name, uint256 price)
    {
        Product memory product = products[_productId];
        return (product.productAddress, product.name, product.price);
    }

    function purchaseProduct(uint256 _productId)
        external
        payable
        productExists(_productId)
    {
        Product memory product = products[_productId];
        require(msg.value >= product.price, "Insufficient funds");

        sales.push(Sale({
            productId: _productId,
            purchaseDate: block.timestamp,
            buyer: msg.sender
        }));

        totalSales++;

        if (msg.value > product.price) {
            payable(msg.sender).transfer(msg.value - product.price);
        }

        emit SaleAdded(sales.length - 1, _productId, msg.sender, block.timestamp);
    }

    function getSale(uint256 _saleId)
        external
        view
        saleExists(_saleId)
        returns (uint256 productId, uint256 purchaseDate, address buyer)
    {
        Sale memory sale = sales[_saleId];
        return (sale.productId, sale.purchaseDate, sale.buyer);
    }

    function getCustomerPurchases(address _customer)
        external
        view
        returns (
            uint256[] memory productIds,
            uint256[] memory purchaseDates,
            uint256 totalAmount,
            uint256 purchaseCount
        )
    {
        SalesUtils.Sale[] memory libSales = new SalesUtils.Sale[](sales.length);
        SalesUtils.Product[] memory libProducts = new SalesUtils.Product[](products.length);

        for (uint256 i = 0; i < sales.length; i++) {
            libSales[i] = SalesUtils.Sale({
                productId: sales[i].productId,
                purchaseDate: sales[i].purchaseDate,
                buyer: sales[i].buyer
            });
        }

        for (uint256 i = 0; i < products.length; i++) {
            libProducts[i] = SalesUtils.Product({
                productAddress: products[i].productAddress,
                name: products[i].name,
                price: products[i].price
            });
        }

        SalesUtils.CustomerPurchases memory customerPurchases =
            SalesUtils.getCustomerPurchase(libSales, libProducts, _customer);

        return (
            customerPurchases.productIds,
            customerPurchases.purchaseDates,
            customerPurchases.totalAmount,
            customerPurchases.purchaseCount
        );
    }

    function getSalesInPeriod(uint256 _startDate, uint256 _endDate)
        external
        view
        returns (uint256 totalSalesAmount)
    {
        SalesUtils.Sale[] memory libSales = new SalesUtils.Sale[](sales.length);
        SalesUtils.Product[] memory libProducts = new SalesUtils.Product[](products.length);

        for (uint256 i = 0; i < sales.length; i++) {
            libSales[i] = SalesUtils.Sale({
                productId: sales[i].productId,
                purchaseDate: sales[i].purchaseDate,
                buyer: sales[i].buyer
            });
        }

        for (uint256 i = 0; i < products.length; i++) {
            libProducts[i] = SalesUtils.Product({
                productAddress: products[i].productAddress,
                name: products[i].name,
                price: products[i].price
            });
        }

        return SalesUtils.calculateSalesInPeriod(libSales, libProducts, _startDate, _endDate);
    }

    function getProductCount() external view returns (uint256) {
        return products.length;
    }

    function getSaleCount() external view returns (uint256) {
        return sales.length;
    }

    function getContractBalance() external view returns (uint256) {
        return address(this).balance;
    }

    function weiToEther(uint256 weiAmount) external pure returns (uint256 etherAmount) {
        return SalesUtils.weiToEther(weiAmount);
    }

    receive() external payable {}
    fallback() external payable {}
}

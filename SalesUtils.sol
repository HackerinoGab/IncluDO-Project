// SPDX-License-Identifier: MIT
pragma solidity ^0.8.1;

library SalesUtils {

    struct Product {
        string name;
        address productAddress;
        uint256 price;
    }

    struct Sale {
        uint256 productId;
        uint256 purchaseDate;
        address buyer;
    }

    struct CustomerPurchases {
        uint256[] productIds;
        uint256[] purchaseDates;
        uint256 totalAmount;
        uint256 purchaseCount;
    }

    function getCustomerPurchase(
        Sale[] memory sales,
        Product[] memory products,
        address customer
    ) internal pure returns (CustomerPurchases memory) {
        uint256 purchaseCount = 0;
        for (uint256 i = 0; i < sales.length; i++) {
            if (sales[i].buyer == customer) {
                purchaseCount++;
            }
        }

        uint256[] memory productIds = new uint256[](purchaseCount);
        uint256[] memory purchaseDates = new uint256[](purchaseCount);
        uint256 totalAmount = 0;
        uint256 index = 0;

        for (uint256 i = 0; i < sales.length; i++) {
            if (sales[i].buyer == customer) {
                productIds[index] = sales[i].productId;
                purchaseDates[index] = sales[i].purchaseDate;
                if (sales[i].productId < products.length) {
                    totalAmount += products[sales[i].productId].price;
                }
                index++;
            }
        }

        return CustomerPurchases({
            productIds: productIds,
            purchaseDates: purchaseDates,
            totalAmount: totalAmount,
            purchaseCount: purchaseCount
        });
    }

    function calculateSalesInPeriod(
        Sale[] memory sales,
        Product[] memory products,
        uint startDate,
        uint endDate
    ) internal pure returns (uint256 totalAmount) {
        require(startDate <= endDate, "Data di inizio deve essere precedente alla data di fine");
        totalAmount = 0;
        for (uint256 i = 0; i < sales.length; i++) {
            if (sales[i].purchaseDate >= startDate && sales[i].purchaseDate <= endDate) {
                if (sales[i].productId < products.length) {
                    totalAmount += products[sales[i].productId].price;
                }
            }
        }
        return totalAmount;
    }

    function productExist(Product[] memory products, uint256 productId) internal pure returns (bool) {
        return (productId < products.length);
    }

    function weiToEther(uint256 weiAmount) internal pure returns (uint256 etherAmount) {
        return weiAmount / 1 ether;
    }
}

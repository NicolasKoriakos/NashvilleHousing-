/* 
	Cleaning data in SQL Queries
*/

SELECT *
FROM NashvilleHousing

--------------------------------------------------------------------------------------------------------------------------

-- Standarize Date Format

SELECT SaleDateConverted, CONVERT(DATE, SaleDate)
From NashvilleHousing

ALTER TABLE NashvilleHousing
ADD SaleDateConverted DATE

UPDATE NashvilleHousing 
SET SaleDateConverted = CONVERT(DATE, SaleDate)



--------------------------------------------------------------------------------------------------------------------------

-- Populate Property Address data

SELECT PropertyAddress
FROM NashvilleHousing
WHERE PropertyAddress IS NULL

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress) AS PA
FROM NashvilleHousing a
JOIN NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM NashvilleHousing a
JOIN NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]

--------------------------------------------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State)

SELECT PropertyAddress
FROM NashvilleHousing

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) AS Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) AS City
FROM NashvilleHousing

ALTER TABLE NashvilleHousing
ADD PropertyAddress1 VARCHAR(255)

UPDATE NashvilleHousing 
SET PropertyAddress1 = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

ALTER TABLE NashvilleHousing
ADD PropertyCity VARCHAR(255)

UPDATE NashvilleHousing 
SET PropertyCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))

SELECT PropertyAddress1, PropertyCity
FROM NashvilleHousing

-- Owner Address

SELECT OwnerAddress
FROM NashvilleHousing

SELECT 
PARSENAME(REPLACE(OwnerAddress,',','.'),3) AS Address, 
PARSENAME(REPLACE(OwnerAddress,',','.'),2) AS City,
PARSENAME(REPLACE(OwnerAddress,',','.'),1) AS State
FROM NashvilleHousing
WHERE OwnerAddress IS NOT NULL


ALTER TABLE NashvilleHousing
ADD OwnerAddress1 VARCHAR(255)

UPDATE NashvilleHousing 
SET OwnerAddress1 = PARSENAME(REPLACE(OwnerAddress,',','.'),3)

ALTER TABLE NashvilleHousing
ADD OwnerCity VARCHAR(255)

UPDATE NashvilleHousing 
SET OwnerCity = PARSENAME(REPLACE(OwnerAddress,',','.'),2)

ALTER TABLE NashvilleHousing
ADD OwnerState VARCHAR(255)

UPDATE NashvilleHousing 
SET OwnerState = PARSENAME(REPLACE(OwnerAddress,',','.'),1)


SELECT OwnerAddress1 , OwnerCity, OwnerState
FROM NashvilleHousing
WHERE OwnerAddress IS NOT NULL



--------------------------------------------------------------------------------------------------------------------------

-- Change Y and N to Yes and No in "Sold as Vacant" field

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2

SELECT SoldAsVacant,
CASE WHEN SoldAsVacant = 'Y' THEN 'Yes' 
	 WHEN SoldAsVacant = 'N' THEN 'NO'
ELSE SoldAsVacant
END
FROM NashvilleHousing

UPDATE NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes' 
						WHEN SoldAsVacant = 'N' THEN 'NO'
						ELSE SoldAsVacant
				   END



--------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates

-- CTE
WITH RowNumCTE AS(
SELECT *,
	ROW_NUMBER() OVER(
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY UniqueID) row_num
FROM NashvilleHousing)

DELETE
FROM RowNumCTE
WHERE row_num > 1


--------------------------------------------------------------------------------------------------------------------------

-- Delete Unused Columns

ALTER TABLE NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate

SELECT * 
FROM NashvilleHousing
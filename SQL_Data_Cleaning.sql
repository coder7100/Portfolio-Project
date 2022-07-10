SELECT *
FROM housingdata;

-- Making a duplicate of our data

CREATE TABLE housingdata_duplicate
AS SELECT * from housingdata;
 
-- Standerize Sale Date
-- While importing the data, the date was in string format. Hence i have converted that format and stored the new date in Sales_date column

ALTER TABLE housingdata
ADD Sales_date date

UPDATE housingdata SET
	Sales_date = STR_TO_DATE(SaleDate,'%M %d,%Y')


-- Converting the blank values into null 


UPDATE housingdata SET
	propertyAddress= NULLIF(propertyAddress,'')

-- Populate Property Address Data

SELECT *
from housingdata
where propertyAddress is NULL

-- so there are multiple rows with same parcel id and each one of them have same address.

SELECT *
FROM housingdata
WHERE ParcelID IN
(SELECT ParcelID
FROM housingdata
WHERE PropertyAddress is NULL)

-- Hence assigning the address properly

UPDATE housingdata a
JOIN housingdata b
on a.ParcelID=b.ParcelID AND a.UniqueID != b.UniqueID
SET a.propertyaddress = IFNULL(a.propertyaddress,b.propertyaddress)
WHERE a.propertyaddress IS NULL

-- Breaking out address into individual columns (address,city,state)

SELECT PropertyAddress
FROM housingdata

SELECT SUBSTRING(PropertyAddress,1,LOCATE(',',PropertyAddress)-1) AS Address,
       SUBSTRING(propertyaddress,LOCATE(',',PropertyAddress)+1,LENGTH(PropertyAddress)) AS City
FROM housingdata


ALTER TABLE housingdata
ADD PropertySplitAddress varchar(255)

UPDATE housingdata 
SET PropertySplitAddress = SUBSTRING(PropertyAddress,1,LOCATE(',',PropertyAddress)-1)
    
ALTER TABLE housingdata
ADD PropertySplitCity varchar(255)

UPDATE housingdata 
SET PropertySplitCity =  SUBSTRING(propertyaddress,LOCATE(',',PropertyAddress)+1,LENGTH(PropertyAddress))

 -- Changing Y and N to Yes and NO
 
 Select Distinct(SoldasVacant),Count(SoldasVacant)
 FROM housingdata
 GROUP BY SoldasVacant
 ORDER BY 2
 
 SELECT SoldasVacant,
 CASE WHEN SoldasVacant = 'Y' THEN 'Yes'
	  WHEN SoldasVacant = 'N' THEN 'No'
      ELSE SoldasVacant
END
FROM housingdata

UPDATE housingdata 
SET SoldasVacant =  CASE WHEN SoldasVacant = 'Y' THEN 'Yes'
	  WHEN SoldasVacant = 'N' THEN 'No'
      ELSE SoldasVacant
END

-- Remove Duplicates

-- Lets first see the duplicate entries

WITH rownumCTE AS(
SELECT *,
ROW_NUMBER() OVER(
	PARTITION BY ParcelID,
				 PropertyAddress,
                 SalePrice,
                 SaleDate,
                 LegalReference
                 ORDER BY 
                 UniqueID
)rownum
FROM housingdata
)

SELECT *
FROM rownumCTE
WHERE rownum >1
ORDER BY PropertyAddress

-- Lets Delete this rows. We will use the same query instead of select we will use delete

WITH rownumCTE AS(
SELECT *,
ROW_NUMBER() OVER(
	PARTITION BY ParcelID,
				 PropertyAddress,
                 SalePrice,
                 SaleDate,
                 LegalReference
                 ORDER BY 
                 UniqueID
)rownum
FROM housingdata
)

DELETE
FROM rownumCTE
WHERE rownum >1
-- ORDER BY PropertyAddress

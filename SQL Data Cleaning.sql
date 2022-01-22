--Cleaning Data in SQL 
SELECT * 
FROM SQL_Data_Cleaning..Housing_Data 


-- Standarize Date Format 

ALTER TABLE Housing_Data 
ADD SalesDateConverted Date

UPDATE Housing_Data
SET SalesDateConverted = CONVERT(Date, saledate)

SELECT SalesDateConverted, CONVERT(Date, saledate)
FROM SQL_Data_Cleaning..Housing_Data 

-- populate property adress data 
-- Now we are seeing the number of nulls we have in the propert adress 
SELECT *
FROM SQL_Data_Cleaning..Housing_Data 
WHERE PropertyAddress IS NULL 
-- After checking the nulls, now we look for any duplicates that migh have the same adresses that are missing 
SELECT * 
FROM SQL_Data_Cleaning..Housing_Data
ORDER BY ParcelID
-- After view duplicates of the null adress were found and they contain the missing adresses (See 45/46 & 57/58) 
-- now we will work on fixing the missing adresses 

--joining the table to itself where the ParcelID is the same but the UniqueID is different (to have a Unique row)
--in Order to remove the duplicated null adresses 
SELECT *
FROM SQL_Data_Cleaning..Housing_Data A
JOIN SQL_Data_Cleaning..Housing_Data B
 ON A.ParcelID = B.ParcelID 
 AND A.[UniqueID ] <> B.[UniqueID ] 

 -- These are the adresses that we have Adress for but not used
 SELECT A.ParcelID, A.PropertyAddress, B.ParcelID, B.PropertyAddress
FROM SQL_Data_Cleaning..Housing_Data A
JOIN SQL_Data_Cleaning..Housing_Data B
 ON A.ParcelID = B.ParcelID 
 AND A.[UniqueID ] <> B.[UniqueID ] 
 Where A.PropertyAddress is null

 --now this code shows us the adress (the last colum) that will be inserted in the null propertyAdress (column 2)
  SELECT A.ParcelID, A.PropertyAddress, B.ParcelID, B.PropertyAddress, ISNULL(A.PropertyAddress, B.PropertyAddress) 
FROM SQL_Data_Cleaning..Housing_Data A
JOIN SQL_Data_Cleaning..Housing_Data B
 ON A.ParcelID = B.ParcelID 
 AND A.[UniqueID ] <> B.[UniqueID ] 
 Where A.PropertyAddress is null

 -- Now we are replacing the null with the adress, after running this code the previous code will show no Nulls 
 UPDATE A
 SET PropertyAddress = ISNULL(A.PropertyAddress, B.PropertyAddress)
 FROM SQL_Data_Cleaning..Housing_Data A
JOIN SQL_Data_Cleaning..Housing_Data B
 ON A.ParcelID = B.ParcelID 
 AND A.[UniqueID ] <> B.[UniqueID ] 
  Where A.PropertyAddress is null


  -- Breaking down adress into individual columns (Adress, City, State)
  
  SELECT PropertyAddress
  FROM SQL_Data_Cleaning..Housing_Data 

  SELECT 
  SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) AS Adress
  , SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, len(PropertyAddress)) AS Adress2
  FROM SQL_Data_Cleaning..Housing_Data
  -- The previous code seperated the Adress from the City 
  
  --Updating the first column that include the first part of the aderess 
  ALTER TABLE Housing_Data
  ADD PropertyAdressP1 Nvarchar(255);

  UPDATE Housing_Data
  SET PropertyAdressP1 = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)

  -- Updating the Second Column that include the second part of the adress (City)
  ALTER TABLE Housing_Data
  ADD PropertyCityP2 Nvarchar(255);

  UPDATE Housing_Data
  SET PropertyCityP2 = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, len(PropertyAddress))

  -- Checking for the new Added columns, and now we can see that we have the two new columns (PropertyAdressP1 & PropertycityP2)
  SELECT * FROM SQL_Data_Cleaning..Housing_Data





  -- Seperating the OwnerAddress in a different way (Parsname) 
  
  SELECT 
  PARSENAME(REPLACE (OwnerAddress, ',' , '.' ),3), 
  PARSENAME(REPLACE (OwnerAddress, ',' , '.' ),2), 
  PARSENAME(REPLACE (OwnerAddress, ',' , '.' ),1) 
  FROM SQL_Data_Cleaning..Housing_Data

  -- -------------------------------------------------------
  -- Now Adding the three new Columns to the Table 
  ALTER TABLE Housing_Data
  ADD OwnerAdressP1 Nvarchar(255);
  --
  UPDATE Housing_Data
  SET OwnerAdressP1 =  PARSENAME(REPLACE (OwnerAddress, ',' , '.' ),3)

  


  ALTER TABLE Housing_Data
  ADD OwnerCityP2 Nvarchar(255);

  UPDATE Housing_Data
  SET OwnerCityP2 = PARSENAME(REPLACE (OwnerAddress, ',' , '.' ),2)


   ALTER TABLE Housing_Data
  ADD OwnerState3 Nvarchar(255);

  UPDATE Housing_Data
  SET OwnerState3 =  PARSENAME(REPLACE (OwnerAddress, ',' , '.' ),1) 

  -- Checking if the new columns are successfully added to the table, and they were added
  SELECT * FROM SQL_Data_Cleaning..Housing_Data

  

  -- Replacing the Y & N in SoldAsCacant with YES and NO 

  SELECT DISTINCT (SoldAsVacant) 
  FROM SQL_Data_Cleaning..Housing_Data -- There are 4 different possibilities (N, Yes, Y, No) we need them to be just Yes & No

   SELECT DISTINCT (SoldAsVacant), COUNT(SoldAsVacant)
  FROM SQL_Data_Cleaning..Housing_Data 
  GROUP BY SoldAsVacant
  ORDER by 2

 SELECT SoldAsVacant,
  CASE WHEN SoldAsVacant = 'Y' THEN 'YES' 
       WHEN SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END As NewSoldAsVacant
FROM SQL_Data_Cleaning..Housing_Data
-- Updating the table to have the new edited YES/No 
UPDATE Housing_Data 
SET SoldAsVacant = 
  CASE WHEN SoldAsVacant = 'Y' THEN 'YES' 
       WHEN SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END 


--- Removing Duplicated 

WITH RowNumCTE AS(
SELECT *, 
  ROW_NUMBER() OVER (
  Partition by ParcelID, 
               PropertyAddress,
			   SalePrice,
			   SaleDate,
			   LegalReference
ORDER BY UniqueID) row_num
From SQL_Data_Cleaning..Housing_Data )
DELETE
FROM ROWNUMCTE
WHERE row_num > 1 
-- After running the Code, 104 Duplicated Rows where Deleted 



--Deleting unused Columns 

ALTER TABLE SQL_Data_Cleaning..Housing_Data
DROP COLUMN 
 OwnerAddress, TaxDistrict, PropertyAddress

 SELECT * FROM SQL_Data_Cleaning..Housing_Data
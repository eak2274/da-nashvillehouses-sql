--SELECT * FROM [NashvilleHouseInfo].[dbo].[NashvilleHouses]

--01. Converting SaleDate datetime type to date
ALTER TABLE dbo.NashvilleHouses
ALTER COLUMN SaleDate date not null
GO

SELECT * FROM [NashvilleHouseInfo].[dbo].[NashvilleHouses]

--02. Populating PropertyAddress field based on values of the PropertyAddress field of the rows having the same value of ParcelID
update 
   nh1
set
   nh1.PropertyAddress = nh2.max_property_address 
from
   dbo.NashvilleHouses nh1
join
   (select ParcelID, max(PropertyAddress) max_property_address 
    from dbo.NashvilleHouses 
	where PropertyAddress is not null 
	group by ParcelID) nh2
   on nh1.ParcelID = nh2.ParcelID
where
   nh1.PropertyAddress is null;

--select * from dbo.NashvilleHouses where ParcelID='108 07 0A 026.00';

--03. Splitting property address and owner address
ALTER TABLE dbo.NashvilleHouses
ADD PropertyStreetAddress VARCHAR(250)

ALTER TABLE dbo.NashvilleHouses
ADD PropertyCity VARCHAR(250)

ALTER TABLE dbo.NashvilleHouses
ADD OwnerStreetAddress VARCHAR(250)

ALTER TABLE dbo.NashvilleHouses
ADD OwnerCity VARCHAR(250)

ALTER TABLE dbo.NashvilleHouses
ADD OwnerState VARCHAR(250)
GO

UPDATE dbo.NashvilleHouses
SET
	PropertyStreetAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1),
	PropertyCity = SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress)),
	OwnerStreetAddress = PARSENAME(REPLACE(OwnerAddress,',','.'),3),
    OwnerCity = PARSENAME(REPLACE(OwnerAddress,',','.'),2),
    OwnerState = PARSENAME(REPLACE(OwnerAddress,',','.'),1);
GO

select
  *
from
   dbo.NashvilleHouses;

--04. Correcting values for SoldAsVacant column
UPDATE dbo.NashvilleHouses
SET SoldAsVacant = CASE
					 WHEN SoldAsVacant = 'Y' THEN 'Yes'
					 WHEN SoldAsVacant = 'N' THEN 'No'
					 ELSE SoldAsVacant
				   END

SELECT distinct SoldAsVacant FROM dbo.NashvilleHouses

--05. Deleting duplicates
with t as
(
	select
	   ROW_NUMBER() over (partition by ParcelID, PropertyAddress, SaleDate, SalePrice, LegalReference, OwnerName, OwnerAddress order by UniqueID) row_num,
	   *
	from
	   dbo.NashvilleHouses
)
--delete 
select *
from t 
where row_num>1 
order by ParcelID

--06. Dropping unneeded columns

select * from dbo.NashvilleHouses

alter table NashvilleHouses
drop column PropertyAddress, OwnerAddress, TaxDistrict

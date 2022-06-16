-- Objective is to clean this data set
select *
FRom [dbo].[NashvilleHousing$]

----------------------------------------------------------------------------------
--- Adjusting to Date formate
Select SaleDateConverted,CONVERT (DATE, Saledate)
from [dbo].[NashvilleHousing$]

Update NashvilleHousing$
SET SaleDate = CONVERT(Date,SaleDate)


ALter table [dbo].[NashvilleHousing$]
Add SaleDateConverted Date;

Update NashvilleHousing$
Set SaleDateConverted = Convert (Date,SaleDate)

------------------------------------------------------------------------------------
---Populate Property Address data 
--- removing null in address due to the fact that the parcell id is the address which coralates with owner address

Select *
from [dbo].[NashvilleHousing$]
Where PropertyAddress is Null
order by ParcelID

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress,ISNULL(a.propertyAddress,b.PropertyAddress)
from [dbo].[NashvilleHousing$]  a
join [dbo].[NashvilleHousing$] b
on a.ParcelID = b.ParcelID
And  a.[UniqueID ]<> b.[UniqueID ]
-- if the parcel id are the same but the unique arent then add the address to the null
Where a.PropertyAddress is null
--- update the orginal data set 

Update a -- must use alias or will return error
SET PropertyAddress= ISNULL(a.propertyAddress , b.PropertyAddress)
from [dbo].[NashvilleHousing$]  a
join [dbo].[NashvilleHousing$] b
on a.ParcelID = b.ParcelID
And  a.[UniqueID ]<> b.[UniqueID ]
Where a.PropertyAddress is null

-- joined it to itself and via joining the table to itself, then update the table
-----------------------------------------------------------------------------------------
-- the objective is to seperate the address into differnt columns 

Select *
from [dbo].[NashvilleHousing$]
--Where PropertyAddress is Null
--order by ParcelID
select 
SUBSTRING(PropertyAddress,1,CHARINDEX(',', PropertyAddress)-1) as Address
,SUBSTRING(PropertyAddress ,CHARINDEX(',', PropertyAddress)+1 , len(propertyAddress))as Address
From [dbo].[NashvilleHousing$]
--- substring to search though propadd and charindex to search for commas postion used for split later

ALTER TABLE NashvilleHousing$
Add PropertySplitAddress Nvarchar(255);

Update NashvilleHousing$
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 )


ALTER TABLE NashvilleHousing$
Add PropertySplitCity Nvarchar(255);

Update NashvilleHousing$
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress))
--- you can't split items into differnt columns so you have to creat new ones

-------------------------------------------------------------------------------------------
--- Found a faster way to do the same thing using parsename
----- it looks for '.' so chnaged the ',' into '.' 
select OwnerAddress
from [dbo].[NashvilleHousing$]

select 
PARSENAME(replace(ownerAddress,',','.'), 3),
PARSENAME(replace(ownerAddress,',','.'), 2),
PARSENAME(replace(ownerAddress,',','.'), 1)
from [dbo].[NashvilleHousing$]

ALTER TABLE NashvilleHousing$
Add OwnerSplitAddress Nvarchar(255);

Update NashvilleHousing$
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)

-- alter table allows me to add, delete, a or modify a column
ALTER TABLE NashvilleHousing$
Add OwnerSplitCity Nvarchar(255); -- adding

Update NashvilleHousing$
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2) --- modify



ALTER TABLE NashvilleHousing$
Add OwnerSplitState Nvarchar(255);

Update NashvilleHousing$
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)



------------------------------------------------------------------------------------------
--Change Y and N to Yes and No in "Sold as Vacant" field
--- using case statement

Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From NashvilleHousing$
Group by SoldAsVacant
order by 2




Select SoldAsVacant
, CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
From NashvilleHousing$


Update NashvilleHousing$
SET SoldAsVacant = CASE 
When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
----------------------------------------------------------------------------
--- removed duplicates 
-- realised I should have made temp table
with RowNumCTE as (
Select *,
	ROW_NUMBER() Over(
	PARTITION by
		PropertyAddress,
		SalePrice,
		SaleDate,
		LegalReference
	ORDER BY UniqueID) row_num
from [dbo].[NashvilleHousing$]
)
delete
From RowNumCTE
Where row_num > 1
--Order by PropertyAddress
------------------------------------------------------------------------------------

--- object remove empty columns
Select *
From [dbo].[NashvilleHousing$]


ALTER TABLE PortfolioProject.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate
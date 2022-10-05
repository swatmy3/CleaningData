/* Cleaning data in SQL queries */
select *
from NashvilleHousing


--Standardize date format
select 
	SaleDateConverted,
	convert(date,SaleDate)
from NashvilleHousing

update NashvilleHousing
set SaleDate = convert(date,saledate)

alter table NashvilleHousing
add SaleDateConverted Date;

update NashvilleHousing
set SaleDate = convert(date,SaleDate)


--Populate property address data
select 
	*
from NashvilleHousing
order by ParcelID

select 
	a.ParcelID,
	a.PropertyAddress,
	b.ParcelID,
	b.PropertyAddress,
	ISNULL(a.PropertyAddress,b.PropertyAddress)
from NashvilleHousing a
join NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

update a
set PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
from NashvilleHousing a
join NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null


--Breaking out address into individual columns (Address, City, State)
select PropertyAddress
from NashvilleHousing

select 
	SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) as address,
	SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, len(PropertyAddress)) as address
from NashvilleHousing

alter table NashvilleHousing
add PropertySplitAddress nvarchar(255);

update NashvilleHousing
set PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)

alter table NashvilleHousing
add PropertySplitCity nvarchar(255);

update NashvilleHousing
set PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, len(PropertyAddress)) 

select *
from NashvilleHousing

select OwnerAddress
from NashvilleHousing

select 
	PARSENAME(replace(OwnerAddress, ',','.'),3),
	PARSENAME(replace(OwnerAddress, ',','.'),2),
	PARSENAME(replace(OwnerAddress, ',','.'),1)
from NashvilleHousing

alter table NashvilleHousing
add OwnerSplitAddress nvarchar(255);

update NashvilleHousing
set OwnerSplitAddress = PARSENAME(replace(OwnerAddress, ',','.'),3)

alter table NashvilleHousing
add OwnerSplitCity nvarchar(255);

update NashvilleHousing
set OwnerSplitCity = PARSENAME(replace(OwnerAddress, ',','.'),2)

alter table NashvilleHousing
add OwnerSplitState nvarchar(255);

update NashvilleHousing
set OwnerSplitState = PARSENAME(replace(OwnerAddress, ',','.'),1)

select *
from NashvilleHousing


--Change Y and N to Yes and No in "Sold as vacant" field
select 
	distinct SoldAsVacant,
	count(SoldAsVacant)
from NashvilleHousing
group by SoldAsVacant
order by SoldAsVacant

select 
	SoldAsVacant,
	case 
		when SoldAsVacant = 'Y' then 'Yes'
		when SoldAsVacant = 'N' then 'No'
		else SoldAsVacant
	end 
from NashvilleHousing

update NashvilleHousing
set SoldAsVacant = case 
		when SoldAsVacant = 'Y' then 'Yes'
		when SoldAsVacant = 'N' then 'No'
		else SoldAsVacant
	end 


--Remove duplicates
with RowNumCTE as (
select 
	*,
	ROW_NUMBER() over (
	partition by ParcelID,
				PropertyAddress,
				SalePrice,
				SaleDate,
				LegalReference
				order by
					UniqueID
	) row_num
from NashvilleHousing)
delete
from RowNumCTE
where row_num >1

with RowNumCTE as (
select 
	*,
	ROW_NUMBER() over (
	partition by ParcelID,
				PropertyAddress,
				SalePrice,
				SaleDate,
				LegalReference
				order by
					UniqueID
	) row_num
from NashvilleHousing)
select *
from RowNumCTE
where row_num >1


--Delete unused columns
select *
from NashvilleHousing

alter table NashvilleHousing
drop column OwnerAddress, TaxDistrict, PropertyAddress

alter table NashvilleHousing
drop column SaleDate
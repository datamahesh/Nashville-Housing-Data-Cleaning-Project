
------------Data Cleaning Project on Nashville Housing Data------------

select 
	* 
from 
	NashvilleHousing


----Standardize Date Format----

select 
	SaleDate, 
	CONVERT(date,SaleDate)
from	
	NashvilleHousing

alter table 
	NashvilleHousing
add 
	SaleDateConverted date;

update 
	NashvilleHousing
set 
	SaleDateConverted = CONVERT(date,SaleDate)


----Populatiuon Property Address Data----

select 
	*
from 
	NashvilleHousing
order by 
	ParcelID

select 
	a.ParcelID,
	a.PropertyAddress,
	b.ParcelID,
	b.PropertyAddress,
	ISNULL(a.PropertyAddress,b.PropertyAddress)
from 
	NashvilleHousing a
	join 
	NashvilleHousing b
on
	a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where 
	a.PropertyAddress is null

update 
	a
set 
	PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
from 
	NashvilleHousing a
	join 
	NashvilleHousing b
on
	a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where 
	a.PropertyAddress is null


----Breaking out Property Address into individual columns (Address,City,State)----
	
select 
	PropertyAddress
from 
	NashvilleHousing

select
	SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)- 1 ) as Address,
	SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress) + 1, LEN(PropertyAddress)) as Address
from 
	NashvilleHousing

alter table 
	NashvilleHousing
add 
	PropertySplitAddress nvarchar(255) ;

update 
	NashvilleHousing
set 
	PropertySplitAddress = SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)- 1 )

alter table 
	NashvilleHousing
add 
	PropertySplitCity nvarchar(255) ;

update 
	NashvilleHousing
set 
	PropertySplitCity = SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress) + 1, LEN(PropertyAddress))


----Breaking down Owner Address into individual columns (Address,City,State)----

select
	OwnerAddress
from
	NashvilleHousing

select
	PARSENAME(replace(OwnerAddress,',','.'),3),
	PARSENAME(replace(OwnerAddress,',','.'),2),
	PARSENAME(replace(OwnerAddress,',','.'),1)
from
	NashvilleHousing
where 
	OwnerAddress is not null

alter table 
	NashvilleHousing
add 
	OwnerSplitAddress nvarchar(255) ;

update 
	NashvilleHousing
set 
	OwnerSplitAddress = PARSENAME(replace(OwnerAddress,',','.'),3)

alter table 
	NashvilleHousing
add 
	OwnerSplitCity nvarchar(255) ;

update 
	NashvilleHousing
set 
	OwnerSplitCity = PARSENAME(replace(OwnerAddress,',','.'),2)

alter table 
	NashvilleHousing
add 
	OwnerSplitState nvarchar(255) ;

update 
	NashvilleHousing
set 
	OwnerSplitState = PARSENAME(replace(OwnerAddress,',','.'),1)


----Change Y and N to Yes and No in "Sold as Vacant" Field----

select
	distinct SoldAsVacant, 
	count(SoldAsVacant)
from
	NashvilleHousing
group by 
	SoldAsVacant
order by 
	2

select
	SoldAsVacant,
	case
		when SoldAsVacant = 'y' then 'Yes'
		when SoldAsVacant = 'n' then 'No'
		else SoldAsVacant
	end
from
	NashvilleHousing

update 
	NashvilleHousing
set
	SoldAsVacant = case
						when SoldAsVacant = 'y' then 'Yes'
						when SoldAsVacant = 'n' then 'No'
						else SoldAsVacant
					end


----Remove Duplicates----

with RownumCTE AS (
select
	*,
	ROW_NUMBER() over( partition by ParcelID,
									PropertyAddress,
									SalePrice,
									SaleDate,
									LegalReference
									order by
										UniqueID) row_num
from
	NashvilleHousing
/*order by
	ParcelID*/
)
delete
from
	RownumCTE
where 
	row_num > 1
/*order by
	PropertyAddress*/


----Delete Unused Columns----

select
	*
from
	NashvilleHousing

alter table 
	NashvilleHousing
drop column OwnerAddress,
			TaxDistrict,
			PropertyAddress,
			SaleDate			
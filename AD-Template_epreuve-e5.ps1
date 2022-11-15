##
## Script PowerShell qui permet de créer rapidement les OU, Utilisateurs et Groupes pour l'épreuve E5
##

## Récupération du domaine
Write-Host "Récupération du domaine en cours..." -ForegroundColor Yellow
$domain = Get-ADDomain
Write-Host "Domaine $domain récupéré." -ForegroundColor Green

Write-Host "Création des unités d'organisation en cours..." -ForegroundColor Yellow

## Création de l'OU OLAB
New-ADOrganizationalUnit -Path $domain -Name "OLAB"

## Récupération de l'OU OLAB
$olab = Get-ADOrganizationalUnit -Filter 'Name -like "OLAB"'

## Création des sous OU
New-ADOrganizationalUnit -Path $olab -Name "Direction"
New-ADOrganizationalUnit -Path $olab -Name "Comptabilité"
New-ADOrganizationalUnit -Path $olab -Name "Marketing"
New-ADOrganizationalUnit -Path $olab -Name "Groupes"

Write-Host "Les unités d'organisation sont bien créées." -ForegroundColor Green

## Récupération des sous OU
$direction = Get-ADOrganizationalUnit -Filter 'Name -like "Direction"'
$compta = Get-ADOrganizationalUnit -Filter 'Name -like "Comptabilité"'
$marketing = Get-ADOrganizationalUnit -Filter 'Name -like "Marketing"'
$groupes = Get-ADOrganizationalUnit -Filter 'Name -like "Groupes"'

Write-Host "Création des utilisateurs en cours..." -ForegroundColor Yellow

## Création des utilisateurs dans les sous OU
New-ADUser `
-Name "Direction" `
-GivenName "Direction" `
-SamAccountName "direction" `
-UserPrincipalName "direction@olab.lan" `
-Path $direction `
-AccountPassword (ConvertTo-SecureString -AsPlainText "Formation2022" -Force) `
-Verbose `
-ChangePasswordAtLogon $false `
-Enabled $true

New-ADUser `
-Name "Compta" `
-GivenName "Compta" `
-SamAccountName "compta" `
-UserPrincipalName "compta@olab.lan" `
-Path $compta `
-AccountPassword (ConvertTo-SecureString -AsPlainText "Formation2022" -Force) `
-Verbose `
-ChangePasswordAtLogon $false `
-Enabled $true

New-ADUser `
-Name "Marketing" `
-GivenName "Marketing" `
-SamAccountName "marketing" `
-UserPrincipalName "marketing@olab.lan" `
-Path $marketing `
-AccountPassword (ConvertTo-SecureString -AsPlainText "Formation2022" -Force) `
-Verbose `
-ChangePasswordAtLogon $false `
-Enabled $true

Write-Host "Création des utilisateurs terminée." -ForegroundColor Green
Write-Host "Création des groupes de sécurité en cours..." -ForegroundColor Yellow

## Création des groupes de sécurité
New-ADGroup -Name "Groupe OLAB Direction" -Path $groupes -GroupScope Global
New-ADGroup -Name "Groupe OLAB Comptabilité" -Path $groupes -GroupScope Global
New-ADGroup -Name "Groupe OLAB Marketing" -Path $groupes -GroupScope Global
New-ADGroup -Name "Groupe OLAB NTFS Direction" -Path $groupes -GroupScope Global
New-ADGroup -Name "Groupe OLAB NTFS Comptabilité" -Path $groupes -GroupScope Global
New-ADGroup -Name "Groupe OLAB NTFS Marketing" -Path $groupes -GroupScope Global

Write-Host "Création des groupes de sécurité terminée." -ForegroundColor Green
Write-Host "Ajout des utilisateurs dans les groupes de sécurité en cours..." -ForegroundColor Yellow

## Ajout des utilisateurs dans leur groupe
Add-AdGroupMember -Identity "Groupe OLAB Direction" -Members "direction"
Add-AdGroupMember -Identity "Groupe OLAB Comptabilité" -Members "compta"
Add-AdGroupMember -Identity "Groupe OLAB Marketing" -Members "marketing"

## Ajout des groupes de services dans les groupes de sécurité
Add-AdGroupMember -Identity "Groupe OLAB NTFS Direction" -Members "Groupe OLAB Direction"
Add-AdGroupMember -Identity "Groupe OLAB NTFS Comptabilité" -Members "Groupe OLAB Comptabilité", "Groupe OLAB Direction"
Add-AdGroupMember -Identity "Groupe OLAB NTFS Marketing" -Members "Groupe OLAB Marketing", "Groupe OLAB Direction"

Write-Host "Ajout des utilisateurs dans les différents groupes de sécurité terminé." -ForegroundColor Green

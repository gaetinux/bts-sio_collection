## 
## Script permettant de choisir et de créer automatiquement une VM sur Hyper-V
##

try {

	## Récupération de la lettre du SSD
	$ssdLetter = Get-Volume -FriendlyName gpawlowski-ssd | ForEach-Object DriveLetter

	if (!$ssdLetter) {

		Write-Host "Le disque dur n'est pas connecté ! Annulation..." -ForegroundColor Red
 
		## Interrompt le script, pas d'action
		exit
	}

	## Vérification des cartes réseaux
	Write-Host "Création des commutateurs virtuels nécessaires." -ForegroundColor Yellow

	## Création carte WAN
	New-VMSwitch -name gpawlowski-WAN -NetAdapterName Ethernet -AllowManagementOS $true -ErrorAction Stop | Out-Null
	## Création carte LAN
	New-VMSwitch -name gpawlowski-LAN -SwitchType Internal -ErrorAction Stop | Out-Null

	Write-Host "Les commutateurs virtuels sont bien créés." -ForegroundColor Green

	## Choix de la VM à créer
	Write-Host "Quelle est la situation retenue ?" -ForegroundColor Yellow
	Write-Host "1 - Windows Server 2019"
	Write-Host "2 - Serveur GLPI"
	$choice = Read-Host "Indiquez le numéro de l'option choisie"
	
	## Création d'un dossier sur le bureau pour stocker le projet
	$desktopPath = [Environment]::GetFolderPath("Desktop")
	New-Item -Path $desktopPath -Name "gpawlowski-e5" -ItemType "directory" | Out-Null
	Write-Host "Création du dossier gpawlowski-e5 sur le bureau ok." -ForegroundColor Green
	$situationPath = "$desktopPath\gpawlowski-e5"	

	switch ($choice) {

		1 {
			
			## Création du DC
			Write-Host "Création du contrôleur de domaine..." -ForegroundColor Yellow
			## Création des dossiers nécessaires
			New-Item -Path $situationPath -Name "vdc1" -ItemType "directory" | Out-Null
			New-Item -Path "$situationPath\vdc1" -Name "Virtual Hard Disks" -ItemType "directory" | Out-Null
			## Copie du Sysprep dans le dossier des VHDX
			Copy-Item -Path "${ssdLetter}:\epreuve-e5\Windows\vdc1.vhdx" -Destination "$situationPath\vdc1\Virtual Hard Disks\"
			$vdc1 = "$situationPath\vdc1\Virtual Hard Disks\vdc1.vhdx"
			## Création de la VM avec intégration du disque Sysprep
			New-VM -Name "vdc1" -MemoryStartupBytes 4GB -Generation 2 -VHDPath $vdc1 -Path $situationPath -SwitchName gpawlowski-lan | Out-Null
			## Désactivation des points de contrôle automatiques
			Set-VM -Name "vdc1" -AutomaticCheckpointsEnabled $False
			## 2 processeurs virtuels
			Set-VMProcessor "vdc1" -Count 2

			## Création du serveur DHCP
			Write-Host "Création du serveur DHCP..." -ForegroundColor Yellow
			## Création des dossiers nécessaires
			New-Item -Path $situationPath -Name "vdhcp1" -ItemType "directory" | Out-Null
			New-Item -Path "$situationPath\vdhcp1" -Name "Virtual Hard Disks" -ItemType "directory" | Out-Null
			## Copie du Sysprep dans le dossier des VHDX
			Copy-Item -Path "${ssdLetter}:\epreuve-e5\Windows\vdhcp1.vhdx" -Destination "$situationPath\vdhcp1\Virtual Hard Disks\"
			$vdhcp1 = "$situationPath\vdhcp1\Virtual Hard Disks\vdhcp1.vhdx"
			## Création de la VM avec intégration du disque Sysprep
			New-VM -Name "vdhcp1" -MemoryStartupBytes 2GB -Generation 2 -VHDPath $vdhcp1 -Path $situationPath -SwitchName gpawlowski-lan | Out-Null
			## Désactivation des points de contrôle automatiques
			Set-VM -Name "vdhcp1" -AutomaticCheckpointsEnabled $False
			## 2 processeurs virtuels
			Set-VMProcessor "vdhcp1" -Count 2

            ## Création de la machine Windows 10
            Write-Host "Création de la machine cliente Windows 10..." -ForegroundColor Yellow
            ## Création des dossiers nécessaires
			New-Item -Path $situationPath -Name "vclient1" -ItemType "directory" | Out-Null
			New-Item -Path "$situationPath\vclient1" -Name "Virtual Hard Disks" -ItemType "directory" | Out-Null
			## Copie du Sysprep dans le dossier des VHDX
			Copy-Item -Path "${ssdLetter}:\epreuve-e5\Windows\vclient1.vhdx" -Destination "$situationPath\vclient1\Virtual Hard Disks\"
			$vclient1 = "$situationPath\vclient1\Virtual Hard Disks\vclient1.vhdx"
			## Création de la VM avec intégration du disque Sysprep
			New-VM -Name "vclient1" -MemoryStartupBytes 4GB -Generation 2 -VHDPath $vclient1 -Path $situationPath -SwitchName gpawlowski-lan | Out-Null
			## Désactivation des points de contrôle automatiques
			Set-VM -Name "vclient1" -AutomaticCheckpointsEnabled $False
			## 2 processeurs virtuels
			Set-VMProcessor "vclient1" -Count 2
		}

		2 {
    
            ## Création du DC
			Write-Host "Création du contrôleur de domaine..." -ForegroundColor Yellow
			## Création des dossiers nécessaires
			New-Item -Path $situationPath -Name "vdc1" -ItemType "directory" | Out-Null
			New-Item -Path "$situationPath\vdc1" -Name "Virtual Hard Disks" -ItemType "directory" | Out-Null
			## Copie du Sysprep dans le dossier des VHDX
			Copy-Item -Path "${ssdLetter}:\epreuve-e5\Windows\vdc1.vhdx" -Destination "$situationPath\vdc1\Virtual Hard Disks\"
			$vdc1 = "$situationPath\vdc1\Virtual Hard Disks\vdc1.vhdx"
			## Création de la VM avec intégration du disque Sysprep
			New-VM -Name "vdc1" -MemoryStartupBytes 4GB -Generation 2 -VHDPath $vdc1 -Path $situationPath -SwitchName gpawlowski-lan | Out-Null
            Add-VMNetworkAdapter -VMName "vdc1" -SwitchName gpawlowski-wan
			## Désactivation des points de contrôle automatiques
			Set-VM -Name "vdc1" -AutomaticCheckpointsEnabled $False
			## 2 processeurs virtuels
			Set-VMProcessor "vdc1" -Count 2

            ## Import du serveur Ubuntu installé et à jour
            Write-Host "Importation du serveur Ubuntu à jour..." -ForegroundColor Yellow
			New-Item -Path $situationPath -Name "glpi" -ItemType "directory" | Out-Null
			New-Item -Path "$situationPath\glpi" -Name "Virtual Hard Disks" -ItemType "directory" | Out-Null
            Import-VM -Path "${ssdLetter}:\epreuve-e5\Linux\glpi\Virtual Machines\349D2C79-5F08-4A29-A103-65F655865561.vmcx" -Copy -GenerateNewId -VhdDestinationPath "$situationPath\glpi\Virtual Hard Disks\" -VirtualMachinePath "$situationPath\glpi\Virtual Machines\" | Out-Null
		}

		default {
    
			Write-Host "La sélection ne correspond à aucun des choix proposés. Opération annulée." -ForegroundColor Red

			## Interrompt le script, pas d'action
			exit
		}
	}

    Write-Host "La création des machines est terminée. Au travail !" -ForegroundColor Green
} catch {

    ## Gestion de l'erreur
    Write-Host $_.Exception.Message -ForegroundColor Red
}

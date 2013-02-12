#include <efi.h>
#include <efilib.h>

EFI_STATUS efi_main(EFI_HANDLE ImageHandle, EFI_SYSTEM_TABLE *SystemTable){
	
	InitializeLib(ImageHandle, SystemTable);
	EFI_BOOT_SERVICES *efi_boot_serv;
	efi_boot_serv = SystemTable->BootServices;
	EFI_STATUS status;
	EFI_MEMORY_DESCRIPTOR *memory_map;
	UINTN descriptor_size, map_key, memory_map_size;
	UINT32 descriptor_version;
	long long int result = 0;
	
	status = uefi_call_wrapper(
								efi_boot_serv->GetMemoryMap, 
								5, 
								&memory_map_size, 
								memory_map,
								&map_key, 
								&descriptor_size, 
								&descriptor_version
								);
	if(status == EFI_BUFFER_TOO_SMALL){	
		status = uefi_call_wrapper(
									efi_boot_serv->AllocatePool, 
									3, 
									EfiLoaderData, 
									memory_map_size, 
									&memory_map
									);
		if(status != EFI_SUCCESS)
			Print(L"Memory allocation failed\n");
			return status;
		}
		
		status = uefi_call_wrapper(
									efi_boot_serv->GetMemoryMap, 
									5, 
									&memory_map_size, 
									memory_map, 
									&map_key, 
									&descriptor_size, 
									&descriptor_version
									);
		if(status != EFI_SUCCESS){
			Print(L"The memory map has not been received\n");
			return status;
		}
		
		int param = memory_map_size/(sizeof(EFI_MEMORY_DESCRIPTOR));
		for(int i = 0; i < param; ++i){
			switch (memory_map[i].Type){
				case EfiConventionalMemory : result += (memory_map[i].NumberOfPages << 12);
				case EfiBootServicesCode : result += (memory_map[i].NumberOfPages << 12);
				case EfiBootServicesData : result += (memory_map[i].NumberOfPages << 12);
			}
		}
		Print(L"%d bytes free memory\n", result);
		uefi_call_wrapper(efi_boot_serv->FreePool, 1, &memory_map);
	}
	else{
		Print(L"The memory map has not been received\n");	
	}
	return EFI_SUCCESS;
}
/**
 * @author: WGVR43 
 * @date: 13.08.2020
 * @group: DTSFPART
 * @description: 
 */

public class DTSFPART_AccountPermissionsWrapper {
	public String mcnPermissions { get; set; }
	public String contactMCNPermissions { get; set; }

	public DTSFPART_AccountPermissionsWrapper(String mcnPermissions, String contactMCNPermissions){
		this.mcnPermissions = mcnPermissions;
		this.contactMCNPermissions = contactMCNPermissions;
	}
}
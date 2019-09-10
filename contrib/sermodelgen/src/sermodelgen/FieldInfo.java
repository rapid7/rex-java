package sermodelgen;

public class FieldInfo {

	private String name;
	private String signature;

	public FieldInfo() {
	}
	
	public FieldInfo(String name) {
		this.name = name;
	}
	
	public String getName() {
		return name;
	}
	
	public void setName(String name) {
		this.name = name;
	}

	public String getTypeString() {
		return signature;
	}
	
	public void setTypeString(String signature) {
		this.signature = signature;
	}
}

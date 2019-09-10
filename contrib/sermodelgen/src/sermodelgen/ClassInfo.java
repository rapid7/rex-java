package sermodelgen;

import java.util.List;

import com.fasterxml.jackson.annotation.JsonInclude;

@JsonInclude(JsonInclude.Include.NON_DEFAULT)
public class ClassInfo {

	private String typeString;
	private long serialVersion;
	private boolean isEnum;
	private boolean externalizable;
	private boolean hasWriteObject;
	private boolean hasReadObject;
	private boolean hasWriteReplace;
	private List<FieldInfo> fields;
	private String superType;
	
	
	public ClassInfo() {
	}

	public ClassInfo(String typeString, long serialVersion) {
		this.typeString = typeString;
		this.serialVersion = serialVersion;
	}

	
	public String getTypeString() {
		return typeString;
	}
	
	public void setTypeString(String name) {
		this.typeString = name;
	}
	
	public String getSuperType() {
		return superType;
	}
	
	public void setSuperType(String superType) {
		this.superType = superType;		
	}
	
	
	public long getSerialVersion() {
		return serialVersion;
	}
	
	public void setSerialVersion(long serialVersion) {
		this.serialVersion = serialVersion;
	}
	
	public boolean isEnum() {
		return isEnum;
	}

	public void setEnum(boolean isEnum) {
		this.isEnum = isEnum;
	}

	public void setExternalizable(boolean externalizable) {
		this.externalizable = externalizable;
	}
	
	
	public boolean isExternalizable() {
		return externalizable;
	}

	public void setHasWriteObject(boolean hasWriteObject) {
		this.hasWriteObject = hasWriteObject;
	}
	
	public boolean isHasWriteObject() {
		return hasWriteObject;
	}

	public void setHasWriteReplace(boolean hasWriteReplace) {
		this.hasWriteReplace = hasWriteReplace;
	}
	
	public boolean isHasWriteReplace() {
		return hasWriteReplace;
	}
	
	public boolean isHasReadObject() {
		return hasReadObject;
	}
	
	public void setHasReadObject(boolean hasReadObject) {
		this.hasReadObject = hasReadObject;
	}

	public void setFields(List<FieldInfo> fields) {
		this.fields = fields;
	}
	

	public List<FieldInfo> getFields() {
		return fields;
	}

	
}

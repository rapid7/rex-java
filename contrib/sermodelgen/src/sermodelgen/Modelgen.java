package sermodelgen;

import java.io.Externalizable;
import java.io.NotSerializableException;
import java.io.ObjectInputStream;
import java.io.ObjectOutputStream;
import java.io.ObjectStreamClass;
import java.io.ObjectStreamField;
import java.io.Serializable;
import java.lang.reflect.Method;
import java.lang.reflect.Modifier;
import java.util.ArrayList;
import java.util.Collection;
import java.util.HashMap;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;
import java.util.Queue;

public class Modelgen {
	private final Map<Class<?>,ClassInfo> done = new HashMap<>();
	private final Queue<Class<?>> types = new LinkedList<>();

	public void run() throws Exception {
		Class<?> cl;
		while ((cl = types.poll()) != null) {
			analyzeClass(cl);
		}
	}
	
	
	public Collection<ClassInfo> getClassInfo() {
		return done.values();
	}

	private void analyzeClass(Class<?> cl) throws Exception {
		ObjectStreamClass osc = ObjectStreamClass.lookupAny(cl);
		ClassInfo ci = new ClassInfo(toTypeString(cl.getName()), osc.getSerialVersionUID());
		this.done.put(cl,ci);

		Class<?> sup = cl.getSuperclass();
		if (sup != null && Serializable.class.isAssignableFrom(sup)) {
			pushTypes(sup);
		}

		if ( sup != Object.class && sup != null ) {
			ci.setSuperType(toTypeString(sup.getName()));
		}
		ci.setEnum(Enum.class.isAssignableFrom(cl));
		ci.setExternalizable(Externalizable.class.isAssignableFrom(cl));
		ci.setHasWriteObject(hasMethod(cl, "writeObject", new Class<?>[] { ObjectOutputStream.class }, Void.TYPE));
		ci.setHasReadObject(cl != Throwable.class && hasMethod(cl, "readObject", new Class<?>[] { ObjectInputStream.class }, Void.TYPE));
		ci.setHasWriteReplace(hasInheritableMethod(cl, "writeReplace", null, Object.class));
		List<FieldInfo> fields = new ArrayList<>();
		ci.setFields(fields);
		for (ObjectStreamField osf : osc.getFields()) {
			FieldInfo fi = new FieldInfo(osf.getName());
			fi.setTypeString(osf.getTypeString() != null ? osf.getTypeString() : String.valueOf(osf.getTypeCode()));
			if (!osf.isPrimitive() && String.class != osf.getType( ) && !Enum.class.isAssignableFrom(osf.getType())) {
				pushTypes(osf.getType());
			}
			fields.add(fi);
		}
	}

	private static String toTypeString(String name) {
		return "L" + name.replace('.', '/') + ";";
	}


	private static boolean hasMethod(Class<?> cl, String name, Class<?>[] argTypes, Class<?> returnType) {
		try {
			Method meth = cl.getDeclaredMethod(name, argTypes);
			meth.setAccessible(true);
			int mods = meth.getModifiers();
			return ((meth.getReturnType() == returnType) && ((mods & Modifier.STATIC) == 0)
					&& ((mods & Modifier.PRIVATE) != 0)) ? true : false;
		} catch (NoSuchMethodException ex) {
			return false;
		}
	}

	private static boolean hasInheritableMethod(Class<?> cl, String name, Class<?>[] argTypes, Class<?> returnType) {
		Method meth = null;
		Class<?> defCl = cl;
		while (defCl != null) {
			try {
				meth = defCl.getDeclaredMethod(name, argTypes);
				break;
			} catch (NoSuchMethodException ex) {
				defCl = defCl.getSuperclass();
			}
		}

		if ((meth == null) || (meth.getReturnType() != returnType)) {
			return false;
		}

		meth.setAccessible(true);

		int mods = meth.getModifiers();
		if ((mods & (Modifier.STATIC | Modifier.ABSTRACT)) != 0) {
			return false;
		} else if ((mods & (Modifier.PUBLIC | Modifier.PROTECTED)) != 0) {
			return true;
		} else if ((mods & Modifier.PRIVATE) != 0) {
			return (cl == defCl) ? true : false;
		} else {
			return true;
		}
	}

	public void pushTypes(String... types) throws ClassNotFoundException, NotSerializableException {
		Class<?>[] classes = new Class[types.length];
		int i = 0;
		for (String type : types) {
			classes[i++] = Class.forName(type);
		}
		pushTypes(classes);
	}

	public void pushTypes(Class<?>... classes) throws NotSerializableException {
		for (Class<?> cl : classes) {
			if (cl.isArray()) {
				cl = cl.getComponentType();
			}
			if (!Serializable.class.isAssignableFrom(cl) && !cl.isInterface() && cl != Object.class) {
				continue;
			}
			
			if (!this.done.containsKey(cl)) {
				this.types.add(cl);
			}
		}
	}

}

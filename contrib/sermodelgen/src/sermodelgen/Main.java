package sermodelgen;

import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.nio.charset.Charset;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.databind.SerializationFeature;

public class Main {

	public static void main(String[] classes) throws Exception {
		Modelgen m = new Modelgen();
		if (classes == null || classes.length == 0) {
			BufferedReader br = new BufferedReader(new InputStreamReader(System.in, Charset.defaultCharset()));
			String line;
			while (( line = br.readLine() ) != null ) {
				m.pushTypes(line.trim());
			}
		}  else {
			m.pushTypes(classes);
		}
		
		m.run();
		ObjectMapper om = new ObjectMapper();
		om.enable(SerializationFeature.INDENT_OUTPUT);
		om.writeValue(System.out, m.getClassInfo());
	}
}

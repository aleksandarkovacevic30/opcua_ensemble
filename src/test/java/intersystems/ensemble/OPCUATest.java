package intersystems.ensemble;

import org.junit.Test;
import static org.junit.Assert.*;

import org.eclipse.milo.opcua.stack.core.types.builtin.StatusCode;

import org.eclipse.milo.opcua.stack.core.types.builtin.DataValue;
import org.eclipse.milo.opcua.stack.core.types.structured.CallMethodResult;
import intersystems.ensemble.OPCUA;
import org.eclipse.milo.opcua.sdk.client.OpcUaClient;
public class OPCUATest {
    @Test public void testMethod() {
        
        OPCUA cl=new OPCUA("opc.tcp://127.0.0.1:62541/milo");
        CallMethodResult res=null;
        OpcUaClient server=null;
        try {
            assertNotNull("server not connected",cl.server);
            cl.connect();
            res=cl.callMethod(new Double[]{Double.valueOf(16.0)},"ns=2;s=Methods","ns=2;s=Methods/sqrt(x)");
            assertNotNull("result did not arrive",res);
            cl.disconnect();
        } catch (Exception e) {
            fail("Exception occured"+e.getMessage());
            e.printStackTrace();
        }
        assertNotNull("result did not arrive",res);
        if (res==null) {
            fail("app is NULL");    
        } else {
            assertEquals(res.getStatusCode(),StatusCode.GOOD);
            assertEquals(res.getOutputArguments().length,1L);
            assertEquals((Double) res.getOutputArguments()[0].getValue(), Double.valueOf(4.0));
        }
    }
    @Test public void testRead() {
        
        OPCUA cl=new OPCUA("opc.tcp://127.0.0.1:62541/milo");
        DataValueResult[] res=null;
        try {
            cl.connect();
            //public DataValue[] read(OpcUaClient client, String text) throws Exception {
            String text="ns=2;s=Dynamic/RandomDouble\n"+
            "ns=2;i=11013\n"+
            "ns=2;s=ComplexTypes/CustomStructTypeVariable";
            res=cl.read(text);
            cl.disconnect();
        } catch (Exception e) {
            e.printStackTrace();
        }
        if (res==null) {
            //fail("app is NULL");    
        } else {
            assertEquals(res.length,3L);
            assertEquals(res[0].getStatusCode(),"good");
            assertEquals(res[1].getStatusCode(),"good");
            assertEquals(res[2].getStatusCode(),"good");
            //assertEquals(res[1].getValue(),0);
        }
    }
}
package intersystems.ensemble;

import java.util.LinkedList;
import java.util.List;
import java.util.concurrent.CompletableFuture;

import com.google.common.collect.ImmutableList;
import org.eclipse.milo.opcua.sdk.client.OpcUaClient;
import org.eclipse.milo.opcua.sdk.client.api.nodes.VariableNode;
import org.eclipse.milo.opcua.stack.core.Identifiers;
import org.eclipse.milo.opcua.stack.core.types.builtin.DataValue;
import org.eclipse.milo.opcua.stack.core.types.builtin.NodeId;
import org.eclipse.milo.opcua.stack.core.types.builtin.Variant;
import org.eclipse.milo.opcua.stack.core.types.enumerated.ServerState;
import org.eclipse.milo.opcua.stack.core.types.enumerated.TimestampsToReturn;
import org.eclipse.milo.opcua.stack.core.types.structured.ReadResponse;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.eclipse.milo.opcua.stack.core.types.structured.CallMethodResult;
import org.eclipse.milo.opcua.stack.core.types.structured.CallMethodRequest;
import java.util.ArrayList;
import com.google.common.collect.ImmutableList;

public class OPCUA extends ConnectionClearing {
    OpcUaClient server;
    
    public OPCUA(String opcuaHostUrl) {
        try {
        this.server=createClient(opcuaHostUrl, "intersystems");
        } catch(Exception e) {
            e.printStackTrace();
        }
    }

    public void connect() throws Exception {
        super.connect(this.server);
    }

    public void disconnect() throws Exception {
        super.disconnect(this.server);
    }

    public static void main(String[] args) throws Exception {
        OPCUA cl;
        if (args.length>0) {
            cl=new OPCUA(args[0]);
        } else {
            cl=new OPCUA("opc.tcp://127.0.0.1:62541/milo");
        }

        DataValueResult[] res=null;
        try {
            cl.connect();
            String text="ns=2;s=Dynamic/RandomDouble\n"+
            "ns=2;i=11013\n"+
            "ns=2;s=ComplexTypes/CustomStructTypeVariable";
            res=cl.read(text);
            for (DataValueResult dv: res) {
                System.out.println("StatusCode:"+dv.getStatusCode());
                System.out.println("Value:"+dv.getValue());
                System.out.println("SourceTime:"+dv.getSourceTime());
                System.out.println("ServerTime:"+dv.getServerTime());
                System.out.println("===========================");
            }
            cl.disconnect();
        } catch (Exception e) {
            e.printStackTrace();
        }
        if (res==null) {
            System.out.println("app is NULL");
        } else {
            System.out.println("results:");
            System.out.println(res[0].getNodeName());
            System.out.println(res[0].getValue());
            System.out.println(res[1].getNodeName());
            System.out.println(res[1].getValue());
            System.out.println(res[2].getNodeName());
            System.out.println(res[2].getValue());
        }
    } 

    //"ns=2;s=HelloWorld","ns=2;s=HelloWorld/sqrt(x)"
    private final Logger logger = LoggerFactory.getLogger(getClass());


    public DataValueResult[] read(String text) throws Exception {
        List<NodeId> nodeIds=new ArrayList<>();
        String lines[] = text.split("\\r?\\n");
        for(int i=0;i<lines.length;i++) {
            nodeIds.add(NodeId.parse(lines[i]));
        }        
        List<DataValue> readResponse = server.readValues(
          0.0, // maxAge
          TimestampsToReturn.Both, 
          ImmutableList.copyOf(nodeIds)
            ).get();
        DataValueResult[] result=new DataValueResult[readResponse.size()];
        for (int j=0;j<readResponse.size();j++) {
            result[j]=new DataValueResult(readResponse.get(j),lines[j]);
        }

        return result;
    }
    
    public CallMethodResult callMethod(Object[] inputs, String objectIDasText, String methodIDasText) throws Exception {
        NodeId objectId = NodeId.parse(objectIDasText);
        NodeId methodId = NodeId.parse(methodIDasText);
        Variant[] variants=new Variant[inputs.length];
        for (int a=0;a<inputs.length;a++){
            variants[a]=new Variant(inputs[a]);
        }
        CallMethodRequest request = new CallMethodRequest(
            objectId,
            methodId,
            variants
        );

        return server.call(request).get();
    }

}

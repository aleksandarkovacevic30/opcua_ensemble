Class OPCUA.OPCUABS Extends Ens.BusinessService
{

Parameter ADAPTER = "OPCUA.InboundAdapter";

Property Adapter As OPCUA.InboundAdapter;

Property TargetConfigName As Ens.DataType.ConfigName;

Parameter SETTINGS = "TargetConfigName:Basic";

Method OnProcessInput(message As %Library.ListOfDataTypes) As %Status
{
	set pRequest=##class(OPCUA.ReadRequest).%New()
	set pRequest.version="0.1"
	set index = 1
	set no=##class(OPCUA.readResult).%New()
	set no.statusCode=message.GetAt(index).getStatusCode()
	set no.value=message.GetAt(index).getValue()
	set no.sourceTime=message.GetAt(index).getSourceTime()
	set no.serverTime=message.GetAt(index).getServerTime()
	set no.nodeName=message.GetAt(index).getNodeName()
	set sc = no.%Save()
	set pRequest.result=no
	$$$LOGINFO("================================")
	$$$LOGINFO(pRequest.result.nodeName)
	$$$LOGINFO(pRequest.result.value)
	$$$LOGINFO("================================")
	set sc = ..SendRequestAsync(..TargetConfigName, .pRequest)
	quit sc
}

}

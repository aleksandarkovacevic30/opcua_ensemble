Class OPCUA.InboundAdapter Extends (Ens.InboundAdapter, OPCUA.Common)
{

/// Establish gateway connection and init java API.
Method OnInit() As %Status
{
	Set sc = $$$OK
	Quit:((..JGService="") && ((..JGHost="") || (..JGPort = ""))) $$$ERROR($$$GeneralError,"Specify JGService setting or JGHost and JGPort settings")
	Quit:((..JGService'="") && '##class(Ens.Director).IsItemEnabled(..JGService)) $$$ERROR($$$GeneralError, $$$FormatText("Java Gateway Service: '%1' is down",..JGService))
	Set sc = ..Connect()
	Quit:$$$ISERR(sc) sc
	Set sc = ..ConnectToOPCUA()
	Quit sc
}

/// Close connection.
Method OnTearDown() As %Status
{
	set sc = ..API.DisconnectToOPCUA()
	Quit sc
}

Method OnTask() As %Status
{
	Set sc = $$$OK	
	$$$LOGINFO(..Nodes)
	#dim result As %Library.ListOfDataTypes
	Try {
		Set sc = ..Read(..Nodes,.result)
	} Catch ex {
		Set sc = ..ExceptionToStatus(ex)
	}
	
	Quit:$$$ISERR(sc)

	Set sc = ..BusinessHost.ProcessInput(result)
	Quit:$$$ISERR(sc)

	Set ..BusinessHost.%WaitForNextCallInterval=1
	Quit sc
}

}

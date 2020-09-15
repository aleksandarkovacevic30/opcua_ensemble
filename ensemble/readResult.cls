Class OPCUA.readResult extends (%Persistent, %XML.Adaptor)
{
	Property nodeName As %String;
	Property statusCode As %String;
	Property value As %String;
	Property sourceTime As %BigInt;
	Property serverTime As %BigInt;
	
}
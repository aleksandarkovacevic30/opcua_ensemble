Class OPCUA.Common Extends %RegisteredObject [ Abstract ]
{

/// Either host or Connection URI: opc.tcp://host:port/whatever
/// If Connection URI is passed, then Port, Credentials and Virtual host properties are ignored.
Property Host As %VarString [ InitialExpression = "opc.tcp://milo.digitalpetri.com:62541/milo" ];

/// List of nodes to read
Property Nodes As %VarString [ InitialExpression = "ns=2;s=Dynamic/RandomDouble" ];

/// Config Name of the Java Gateway service controlling the Java Gateway server this item will use.
/// Alternatively use JGHost and JGPort Settings, to specify Java gateway outside of Ensemble scope.
Property JGService As %String;

/// Hostname of the Java Gateway server this item will use.
/// Alternatively use JGService Setting, to specify Java gateway inside Ensemble.
Property JGHost As %String[ InitialExpression = "localhost" ];

/// Port of the Java Gateway server this item will use.
/// Alternatively use JGService Setting, to specify Java gateway inside Ensemble.
Property JGPort As %Integer[ InitialExpression = 55555 ];

/// Gateway connection
Property JGW As %Net.Remote.Gateway;

/// API object
Property API As intersystems.ensemble.OPCUA;

/// CLASSPATH containing the files required to be passed as an argument when starting the JVM.
/// The user should typically provide here the files containing the classes used via the Java Gateway. 
/// We assume that the user has properly quoted the classpath and supplied the correct separators for the platform
/// in case of multiple files. <br>
/// See property AdditionalPaths in that class.
Property ClassPath As %String(MAXLEN = 32000);

/// These are the production settings for this object
Parameter SETTINGS = "Host:Basic,Nodes:Basic,JGHost:Java Gateway,JGPort:Java Gateway,JGService:Java Gateway:selector?context={Ens.ContextSearch/ProductionItems?targets=0&productionName=@productionId},ClassPath:Basic,Encoding:Basic";

/// Connect to running JGW 
Method Connect() As %Status
{
    // connect to current namespace, use 2 second timeout
    Set sc = $$$OK
    Set timeout = 5
    Set classPath = ##class(%ListOfDataTypes).%New()
    Do classPath.Insert(..ClassPath)

    // get a connection handle and connect
    Set gateway = ##class(%Net.Remote.Gateway).%New()
    If ..JGService'="" {
		Set host = ##class(Ens.Director).GetHostSettingValue(..JGService, "Address")
		Set port = ##class(Ens.Director).GetHostSettingValue(..JGService, "Port")
    } Else {
	    Set host = ..JGHost
		Set port = ..JGPort
    }
    
    Set sc = gateway.%Connect(host, port, $namespace, timeout, classPath)

    If $$$ISOK(sc) {
	    Set ..JGW = gateway
    }
    Quit sc
}

Method ConnectToOPCUA() As %Status
{
	Set sc = $$$OK
		
	Try {
		If $IsObject(..API) {
			Do ..API.disconnect()
			Set ..API = $$$NULLOREF
		}
		
		Set ..API = ##class(intersystems.ensemble.OPCUA).%New(..JGW, ..Host)
		do ..API.connect()
	} Catch ex {
		Set sc = ..ExceptionToStatus(ex)
	}
	
	Quit sc
}

Method DisconnectToOPCUA() As %Status
{
	Set sc = $$$OK
	Try {
		If $IsObject(..API) {
			Do ..API.disconnect()
			Set ..API = $$$NULLOREF
		}
	} Catch ex {
		Set sc = ..ExceptionToStatus(ex)
	}
	Quit sc
}

Method Read(nodes As %VarString, ByRef result As %Library.ArrayOfDataTypes) As %Status
{
	Set sc = $$$OK
	Try {
		If $IsObject(..API) {
			set result = ..API.read(nodes)
		} 
	} Catch ex {
		Set sc = ..ExceptionToStatus(ex)
	}
	
	Quit sc
}

Method ExceptionToStatus(ex As %Exception.General) As %Status
{
	#Dim sc As %Status
	If ((ex.Name="<ZJGTW>") && $d(%objlasterror)) {
		Set sc = %objlasterror
	} Else {
		Set sc = ex.AsStatus()
	}
    Quit sc
}

}

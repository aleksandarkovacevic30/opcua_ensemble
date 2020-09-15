/// create the production with java gateway and save production --!>
/// import classes which are required -->
/// Installer for the container release of PythonGateway
Class OPCUA.Installer
{

XData Install [ XMLNamespace = INSTALLER ]
{
<Manifest>
  <Var Name="pwd" Value="SYS"/> 
  <User Username="SuperUser" ChangePassword="0" PasswordVar="pwd" Roles="%All" Enabled="1"/>
  <Default Name="NAMESPACE" Value="ENSEMBLE"/>
  <Default Name="DBNAME" Value="${NAMESPACE}"/>
  <Default Name="SOURCESPATH" Dir='#{$system.Util.GetEnviron("SRC_DIR")}' />
  <Default Name="RESOURCE" Value="%DB_${DBNAME}" /> 
  <Namespace Name="${NAMESPACE}">

    <Log Level="1" Text="Importing classes"/>
    <Import File="${SOURCESPATH}ensemble/TestProduction.cls"/>
    <Log Level="1" Text="Running installation"/>
    <Invoke Class="OPCUA.Installer" Method="run">
    </Invoke>
    <Log Level="1" Text="Starting with compiling classes"/>
    <Import File="${SOURCESPATH}ensemble/readResult.cls"/>
    <Import File="${SOURCESPATH}ensemble/ReadRequest.cls"/>
    <Import File="${SOURCESPATH}ensemble/Common.cls"/>
    <Import File="${SOURCESPATH}ensemble/InboundAdapter.cls"/>
    <Import File="${SOURCESPATH}ensemble/OPCUABS.cls"/>
    <Import File="${SOURCESPATH}ensemble/TestCommon.cls"/>
    <Import File="${SOURCESPATH}ensemble/BP.cls"/>
    <Import File="${SOURCESPATH}ensemble/Production.cls"/>
    <Log Level="1" Text="Setting Production"/>
    <Production Name="OPCUA.Production"  AutoStart="1" />
    
  </Namespace>
</Manifest>
}

ClassMethod Setup(ByRef pVars, pLogLevel As %Integer = 3, pInstaller As %Installer.Installer, pLogger As %Installer.AbstractLogger) As %Status [ CodeMode = objectgenerator, Internal ]
{
  Quit ##class(%Installer.Manifest).%Generate(%compiledclass, %code, "Install")
}

ClassMethod run() As %Status
{
   do ##class(Ens.Director).StartProduction("OPCUA.TestProduction")
   // get a connection to the Java Gateway
   set gwyConn = ##class(%Net.Remote.Gateway).%New()
   set status = gwyConn.%Connect("127.0.0.1", 55555, "ENSEMBLE")
   if $$$ISERR(status) {
                write !,"error heyhey: "_$system.OBJ.DisplayError(status)
                quit
   }
   // add the jar to the classpath
   set classpath = ##class(%ListOfDataTypes).%New()
   do classpath.Insert($system.Util.GetEnviron("SRC_DIR")_"/opcua")
   set status = gwyConn.%AddToCurrentClassPath(classpath)
   if $$$ISERR(status) {
                write !,"error: "_$system.OBJ.DisplayError(status)
                quit
   }
   // create the proxy ObjectScript classes that correspond to the Java classes in the jar file
   set status = gwyConn.%Import("intersystems.ensemble.OPCUA",)
   if $$$ISERR(status) {
                write !,"error: "_$system.OBJ.DisplayError(status)
                quit
   }
   set status = gwyConn.%Import("intersystems.ensemble.DataValueResult",)
   if $$$ISERR(status) {
                write !,"error: "_$system.OBJ.DisplayError(status)
                quit
   }
   // close the connection to the Java gateway
   set status = gwyConn.%Disconnect()
   if $$$ISERR(status) {
                write !,"error: "_$system.OBJ.DisplayError(status)
                quit
   }
}

}

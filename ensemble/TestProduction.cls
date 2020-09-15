Class OPCUA.TestProduction Extends Ens.Production
{

XData ProductionDefinition
{
<Production Name="OPCUA.TestProduction" LogGeneralTraceEvents="false">
  <Description></Description>
  <ActorPoolSize>2</ActorPoolSize>
  <Item Name="JGW" Category="" ClassName="EnsLib.JavaGateway.Service" PoolSize="1" Enabled="true" Foreground="false" Comment="" LogTraceEvents="false" Schedule="">
    <Setting Target="Host" Name="ClassPath">/home/cacheusr/opcua/</Setting>
  </Item>
</Production>
}

}

Class OPCUA.Production Extends Ens.Production
{

XData ProductionDefinition
{
<Production Name="OPCUA.Production" LogGeneralTraceEvents="false">
  <Description></Description>
  <ActorPoolSize>2</ActorPoolSize>
  <Item Name="JGW" Category="" ClassName="EnsLib.JavaGateway.Service" PoolSize="1" Enabled="true" Foreground="false" Comment="" LogTraceEvents="false" Schedule="">
    <Setting Target="Host" Name="ClassPath">/home/cacheusr/opcua/</Setting>
  </Item>
  <Item Name="OPCUA.BP" Category="" ClassName="OPCUA.BP" PoolSize="1" Enabled="true" Foreground="false" Comment="" LogTraceEvents="false" Schedule="">
  </Item>
  <Item Name="OPCUA.OPCUABS" Category="" ClassName="OPCUA.OPCUABS" PoolSize="1" Enabled="true" Foreground="false" Comment="" LogTraceEvents="false" Schedule="">
    <Setting Target="Host" Name="TargetConfigName">OPCUA.BP</Setting>
    <Setting Target="Adapter" Name="ClassPath">/home/cacheusr/opcua</Setting>
    <Setting Target="Adapter" Name="JGHost">localhost</Setting>
    <Setting Target="Adapter" Name="JGPort">55555</Setting>
    <Setting Target="Adapter" Name="JGService">JGW</Setting>
    <Setting Target="Adapter" Name="Nodes">ns=2;s=Dynamic/RandomDouble</Setting>
  </Item>
</Production>
}

}

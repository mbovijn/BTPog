class BTGhostPuppet expands Decoration;

function Spawned()
{
	Mesh = Owner.default.Mesh;
	Skin = Owner.default.Skin;
	DrawScale = Owner.DrawScale;
	if(Owner.Multiskins[0] != None)
		Multiskins[0] = Owner.Multiskins[0];
	if(Owner.Multiskins[1] != None)
		Multiskins[1] = Owner.Multiskins[1];
	if(Owner.Multiskins[2] != None)
		Multiskins[2] = Owner.Multiskins[2];
	if(Owner.Multiskins[3] != None)
		Multiskins[3] = Owner.Multiskins[3];
	if(Owner.Multiskins[4] != None)
		Multiskins[4] = Owner.Multiskins[4];
	if(Owner.Multiskins[5] != None)
		Multiskins[5] = Owner.Multiskins[5];
	if(Owner.Multiskins[6] != None)
		Multiskins[6] = Owner.Multiskins[6];
	if(Owner.Multiskins[7] != None)
		Multiskins[7] = Owner.Multiskins[7];
	LoopAnim('Breath2');
}

function Tick(float DeltaTime)
{
	if (Owner == None)
		Destroy();
}

defaultproperties
{
	AmbientGlow=64
	bUnlit=False
	LightBrightness=255
	LightHue=20
	LightSaturation=64
	LightEffect=LE_Shock
	LightRadius=8
	LightType=LT_Steady
	DrawType=DT_Mesh
	Style=STY_Translucent
	bNoDelete=false
	bStatic=false
	bCollideActors=true
}

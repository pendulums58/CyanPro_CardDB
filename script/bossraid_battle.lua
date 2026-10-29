--보스레이드용 함수들 모음
bossraid=bossraid or {}
EVENT_WEREWOLF_DAMAGE=560
EVENT_BOSS_DAMAGED=561

raidcard_monster_codes={101223011}
raidcard_spell_codes={101223012,101223022}
raidcard_trap_codes={101223012,101223022}
raidcard_werewolf_codes={101223047,101223048,101223049,101223050}

function bossraid.callrandomcard(ty)
	math.randomseed(os.time())
	local ct=0
	if ty==nil then
		local t=math.random(1,3)
		if t==1 then ty=TYPE_MONSTER end
		if t==2 then ty=TYPE_SPELL end
		if t==3 then ty=TYPE_TRAP end
	end
	if ty==TYPE_MONSTER then
		ct=math.random(1,#raidcard_monster_codes)
		return raidcard_monster_codes[ct]
	end
	if ty==TYPE_SPELL then
		ct=math.random(1,#raidcard_spell_codes)
		return raidcard_spell_codes[ct]
	end
	if ty==TYPE_TRAP then
		ct=math.random(1,#raidcard_trap_codes)
		return raidcard_trap_codes[ct]
	end
	return 0
end
function cyan.AddCannotExtraMat(c)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_UNRELEASABLE_SUM)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_UNRELEASABLE_NONSUM)
	c:RegisterEffect(e2)
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e3:SetCode(EFFECT_CANNOT_BE_LINK_MATERIAL)
	e3:SetValue(1)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCode(EFFECT_CANNOT_BE_SYNCHRO_MATERIAL)
	c:RegisterEffect(e4)
	local e5=e4:Clone()
	e5:SetCode(EFFECT_CANNOT_BE_XYZ_MATERIAL)
	c:RegisterEffect(e5)
	local e6=e4:Clone()
	e6:SetCode(EFFECT_CANNOT_BE_FUSION_MATERIAL)
	c:RegisterEffect(e6)
	local e7=e4:Clone()
	e7:SetCode(EFFECT_CANNOT_BE_ACCESS_MATERIAL)
	c:RegisterEffect(e7)
	local e8=e4:Clone()
	e8:SetCode(EFFECT_CANNOT_BE_PAIRING_MATERIAL)
	c:RegisterEffect(e8)
end
function Card.GetStar(c)
	local lv=c:GetLevel()
	if c:IsType(TYPE_XYZ) then lv=c:GetRank() end
	if c:IsType(TYPE_LINK) then lv=c:GetLink() end
	return lv
end
function cyan.bossphase()
	local g=Duel.GetMatchingGroup(bossraid.checkboss,0,LOCATION_MZONE,LOCATION_MZONE,nil)
	local tc=g:GetFirst()
	return tc.Boss_Phase
end
function bossraid.checkboss(c)
	return c.Boss_Raid==true
end
function bossraid.InitBossSetting(c,val)
	--게임 시작 전에 적용하는 보스 속성 세팅
	local mt=_G["c"..c:GetCode()]
	--소환의 소재로 할 수 없음. 릴리스할 수 없음.
	cyan.AddCannotExtraMat(c)
	--게임 시작 시, 필드에 세팅됨
	local eb1=Effect.CreateEffect(c)
	eb1:SetCode(EVENT_PREDRAW)
	eb1:SetRange(LOCATION_DECK)
	eb1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	eb1:SetCondition(bossraid.BossSetCon)
	eb1:SetOperation(bossraid.BossSetOp)
	c:RegisterEffect(eb1)
	local eb2=eb1:Clone()
	eb2:SetRange(LOCATION_HAND)
	c:RegisterEffect(eb2)
	--체력 표시
	local eb3=Effect.CreateEffect(c)
	eb3:SetType(EFFECT_TYPE_SINGLE)
	eb3:SetProperty(0x2040600)
	eb3:SetCode(EFFECT_SET_DEFENSE_FINAL)
	eb3:SetRange(LOCATION_MZONE)
	eb3:SetValue(bossraid.ShowBossHp)
	c:RegisterEffect(eb3)
	--턴 종료시마다 상대에게 넘어감
	local eb4=Effect.CreateEffect(c)
	eb4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	eb4:SetCode(EVENT_PREDRAW)
	eb4:SetProperty(0x2040600)
	eb4:SetRange(LOCATION_MZONE)
	eb4:SetOperation(bossraid.ControlOp)
	c:RegisterEffect(eb4)
	--체력이 0이 되면 플레이어의 승리!
	local e8=Effect.CreateEffect(c)
	e8:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e8:SetCode(EVENT_ADJUST)
	e8:SetRange(LOCATION_MZONE)
	e8:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE)
	e8:SetOperation(bossraid.Clear)
	c:RegisterEffect(e8)
	--전투 데미지를 체력 데미지로 변환
	local eb5=Effect.CreateEffect(c)
	eb5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	eb5:SetCode(EVENT_PRE_BATTLE_DAMAGE)
	eb5:SetOperation(bossraid.BattleDamOp)
	eb5:SetProperty(0x2040600)
	eb5:SetRange(LOCATION_MZONE)
	c:RegisterEffect(eb5)
	local eb6=Effect.CreateEffect(c)
	eb6:SetType(EFFECT_TYPE_SINGLE)
	eb6:SetProperty(EFFECT_FLAG_SINGLE_RANGE+0x2040600)
	eb6:SetRange(LOCATION_MZONE)
	eb6:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	eb6:SetValue(1)
	c:RegisterEffect(eb6)
    --파괴 및 제외 대신
    local eb7=Effect.CreateEffect(c)
    eb7:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
    eb7:SetCode(EFFECT_DESTROY_REPLACE)
    eb7:SetProperty(EFFECT_FLAG_SINGLE_RANGE+0x2040600)
    eb7:SetRange(LOCATION_MZONE)
    eb7:SetTarget(bossraid.DesDamTg(val))
    c:RegisterEffect(eb7) 
    local eb8=Effect.CreateEffect(c)
    eb8:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
    eb8:SetCode(EFFECT_SEND_REPLACE)
    eb8:SetProperty(EFFECT_FLAG_SINGLE_RANGE+0x2040600)
    eb8:SetRange(LOCATION_MZONE)
	eb8:SetValue(1)
    eb8:SetTarget(bossraid.RemDamTg(val))
    c:RegisterEffect(eb8) 
end
function bossraid.BossSetCon(e,tp,eg,ep,ev,re,r,rp)
	local code=e:GetHandler():GetCode()
	return Duel.GetFlagEffect(tp,code)==0
end
function bossraid.BossSetOp(e,tp,eg,ep,ev,re,r,rp)
	local code=e:GetHandler():GetCode()
	Duel.RegisterFlagEffect(tp,code,nil,0,1)
	Duel.RegisterFlagEffect(1-tp,code,nil,0,1)
	Duel.BreakEffect()
	local c=e:GetHandler()
	if c:IsLocation(LOCATION_HAND) then 
		Duel.Draw(tp,1,REASON_RULE)
	end
	local ttp=Duel.GetTurnPlayer()
	Duel.MoveToField(c,tp,tp,LOCATION_MZONE,POS_FACEUP_ATTACK,true)
	if tp==ttp then
		Duel.GetControl(c,1-ttp)
	end
	if c.Select_WereWolf==true then
		local g=Group.CreateGroup()
		for i=1,#raidcard_werewolf_codes do
			g:AddCard(Duel.CreateToken(tp,raidcard_werewolf_codes[i]))
		end
		local tpwr=g:Select(tp,1,1,nil)
		g:Sub(tpwr)
		Duel.SpecialSummon(tpwr,0,tp,tp,false,false,POS_FACEUP_ATTACK)
		if c.Must_WereWolf>0 and not tpwr:GetFirst():IsCode(c.Must_WereWolf) then
			local ttpwr=Duel.CreateToken(1-tp,c.Must_WereWolf)
			Duel.SpecialSummon(ttpwr,0,1-tp,1-tp,false,false,POS_FACEUP_ATTACK)
		else
			local ttpwr=g:Select(tp,1,1,nil)
			Duel.SpecialSummon(ttpwr,0,1-tp,1-tp,false,false,POS_FACEUP_ATTACK)
		end
	end
end
function bossraid.ShowBossHp(e)
	local mt=_G["c"..e:GetHandler():GetCode()]
	return mt.Boss_Hp
end
function bossraid.ControlOp(e,tp,eg,ep,ev,re,r,rp)
	local mct=Duel.GetLocationCount(1-tp,LOCATION_MZONE)
	while mct<=0 do
		local g=Duel.GetMatchingGroup(aux.TRUE,1-tp,LOCATION_MZONE,0,nil)
		if g:GetCount()>0 then
			Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_TOGRAVE)
			local sg=g:Select(1-tp,1,1,nil)
			Duel.HintSelection(sg)
			Duel.SendtoGrave(sg,REASON_RULE)
		end	
		mct=Duel.GetLocationCount(1-tp,LOCATION_MZONE)		
	end
	Duel.GetControl(e:GetHandler(),1-tp)
end
function bossraid.Clear(e,tp,eg,ep,ev,re,r,rp)
	local WIN_REASON_DESTINY_LEO=0x17
	if bossraid.ShowBossHp(e)<=0 then
		Duel.Win(tp,WIN_REASON_DESTINY_LEO)
	end
end
function bossraid.BattleDamOp(e,tp,eg,ep,ev,re,r,rp)
	local mt=_G["c"..e:GetHandler():GetCode()]
	local tc=Duel.GetAttackTarget()
	if tc and tc==e:GetHandler() then
		if Duel.GetBattleDamage(tp)<=0 then return end
		local dam=ev
		if dam>mt.Boss_Hp then dam=mt.Boss_Hp end
		mt.Boss_Hp=mt.Boss_Hp-dam	
		Duel.ChangeBattleDamage(tp,0)
	end
end
function bossraid.DesDamTg(val)
	return function (e,tp,eg,ep,ev,re,r,rp,chk)
		local mt=_G["c"..e:GetHandler():GetCode()]
		local c=e:GetHandler()
		if chk==0 then return not c:IsReason(REASON_REPLACE) end
		local dam=0
		local rc=re:GetHandler()
		if rc:IsType(TYPE_MONSTER) and rc:GetAttack()>0 then
			dam=math.floor(rc:GetAttack()/2)
		end
		if rc:IsType(TYPE_SPELL) then
			dam=val
		end
		if rc:IsType(TYPE_TRAP) then
			dam=val*3
		end
		mt.Boss_Hp=mt.Boss_Hp-dam
		return true
	end
end
function bossraid.RemDamTg(val)
	return function (e,tp,eg,ep,ev,re,r,rp,chk)
		local mt=_G["c"..e:GetHandler():GetCode()]
		local c=e:GetHandler()
		if chk==0 then return not c:IsReason(REASON_REPLACE) end
		local dam=0
		if c:GetDestination()==LOCATION_REMOVED then
			local rc=re:GetHandler()
			if rc:IsType(TYPE_MONSTER) and rc:GetAttack()>0 then
				dam=math.floor(rc:GetAttack())
			end
			if rc:IsType(TYPE_SPELL) then
				dam=val*2
			end
			if rc:IsType(TYPE_TRAP) then
				dam=val*6
			end
			mt.Boss_Hp=mt.Boss_Hp-dam
		end
		return true
	end
end
function bossraid.DamageToLower(d,r)
	--가장 낮은 HP / LP의 대상에게 데미지. 매개변수는 damage / reason
	
	local tp=0
	local tlp=Duel.GetLP(tp)
	local ttlp=Duel.GetLP(1-tp)
	local twhp=bossraid.GetWereWolfHp(tp)
	local ttwhp=bossraid.GetWereWolfHp(1-tp)
	if tlp<=ttlp and tlp<=twhp and tlp<=ttwhp then
		return Duel.Damage(tp,d,r)
	elseif twhp<=tlp and twhp<=ttlp and twhp<=ttwhp then
		return bossraid.DamageToWereWolf(tp,d,r)
	elseif ttlp<=tlp and ttlp<=twhp and ttlp<=ttwhp then
		return Duel.Damage(1-tp,d,r)
	else
		return bossraid.DamageToWereWolf(1-tp,d,r)
	end
end
function bossraid.GetWereWolfHp(p)
	--해당 플레이어의 워울프소녀의 체력을 return한다.
	local wr=Duel.GetMatchingGroup(bossraid.IsWereWolf,p,LOCATION_MZONE,0,1,nil)
	if wr:GetCount()>0 then return wr:GetFirst().Werewolf_Hp end
	return 0
end
function bossraid.IsWereWolf(c)
	if c.Werewolf then return true end
	return false
end
function bossraid.DamageToWereWolf(p,dam,r)
	--해당 플레이어의 워울프소녀의 체력을 return한다.
	local wr=Duel.GetMatchingGroup(bossraid.IsWereWolf,p,LOCATION_MZONE,0,1,nil)
	if wr:GetCount()>0 then
		local tc=wr:GetFirst()
		local mt=_G["c"..tc:GetCode()]
		mt.Werewolf_Hp=mt.Werewolf_Hp-dam
		Duel.RaiseEvent(tc,EVENT_WEREWOLF_DAMAGE,nil,REASON_EFFECT,nil,nil,dam)	
	end	
end
function bossraid.WerewolfSetting(c,val)
	--워울프소녀 속성 세팅
	local mt=_G["c"..c:GetCode()]
	--소환의 소재로 할 수 없음. 릴리스할 수 없음.
	cyan.AddCannotExtraMat(c)
	--수비력 칸에 체력 표시
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(0x2040600)
	e3:SetCode(EFFECT_SET_DEFENSE_FINAL)
	e3:SetRange(LOCATION_MZONE)
	e3:SetValue(bossraid.ShowWolfHp)
	c:RegisterEffect(e3)
	--파괴 / 제외되는 경우, 대신에 피해를 받음.
	--약점이라면 2배, 내성이라면 절반의 피해만 받음.
    local e4=Effect.CreateEffect(c)
    e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
    e4:SetCode(EFFECT_DESTROY_REPLACE)
    e4:SetProperty(EFFECT_FLAG_SINGLE_RANGE+0x2040600)
    e4:SetRange(LOCATION_MZONE)
    e4:SetTarget(bossraid.WerewolfDesTg(val))
    c:RegisterEffect(e4) 
    local e5=Effect.CreateEffect(c)
    e5:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
    e5:SetCode(EFFECT_SEND_REPLACE)
    e5:SetProperty(EFFECT_FLAG_SINGLE_RANGE+0x2040600)
    e5:SetRange(LOCATION_MZONE)
	e5:SetValue(1)
    e5:SetTarget(bossraid.WerewolfRmTg(val))
    c:RegisterEffect(e5) 
	--받는 데미지를 체력 데미지로 변환
	local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e6:SetCode(EVENT_DAMAGE)
	e6:SetOperation(bossraid.WerewolfDamop)
	e6:SetProperty(0x2040600)
	e6:SetRange(LOCATION_MZONE)
	c:RegisterEffect(e6)
	local e7=Effect.CreateEffect(c)
	e7:SetType(EFFECT_TYPE_SINGLE)
	e7:SetProperty(EFFECT_FLAG_SINGLE_RANGE+0x2040600)
	e7:SetRange(LOCATION_MZONE)
	e7:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e7:SetValue(1)
	c:RegisterEffect(e7)
	--체력이 0이 되면 플레이어의 패배
	local e8=Effect.CreateEffect(c)
	e8:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e8:SetCode(EVENT_ADJUST)
	e8:SetRange(LOCATION_MZONE)
	e8:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE)
	e8:SetOperation(bossraid.Failed)
	c:RegisterEffect(e8)	
end
function bossraid.ShowWolfHp(e)
	local mt=_G["c"..e:GetHandler():GetCode()]
	return mt.Werewolf_Hp
end
function bossraid.WerewolfDesTg(val)
	return function (e,tp,eg,ep,ev,re,r,rp,chk)
		local mt=_G["c"..e:GetHandler():GetCode()]
		local c=e:GetHandler()
		if chk==0 then return not c:IsReason(REASON_REPLACE) end
		local dam=0
		local rc=re:GetHandler()
		if rc:IsType(TYPE_MONSTER) and rc:GetAttack()>0 then
			dam=math.floor(rc:GetAttack()/2)
			if c.Weakness and c.Weakness==TYPE_MONSTER then dam=rc:GetAttack() end
			if c.Resist and c.Resist==TYPE_MONSTER then dam=math.floor(rc:GetAttack()/4) end
		end
		if rc:IsType(TYPE_SPELL) then
			dam=val
			if c.Weakness and c.Weakness==TYPE_SPELL then dam=val*2 end
			if c.Resist and c.Resist==TYPE_SPELL then dam=math.floor(val/2) end
		end
		if rc:IsType(TYPE_TRAP) then
			dam=val
			if c.Weakness and c.Weakness==TYPE_TRAP then dam=val*2 end
			if c.Resist and c.Resist==TYPE_TRAP then dam=math.floor(val/2) end
		end
		bossraid.DamageToWereWolf(c,dam,REASON_EFFECT)
		return true
	end
end
function bossraid.WerewolfRmTg(val)
	return function (e,tp,eg,ep,ev,re,r,rp,chk)
		local mt=_G["c"..e:GetHandler():GetCode()]
		local c=e:GetHandler()
		if chk==0 then return not c:IsReason(REASON_REPLACE) end
		local dam=0
		if c:GetDestination()==LOCATION_REMOVED then
			local rc=re:GetHandler()
			if rc:IsType(TYPE_MONSTER) and rc:GetAttack()>0 then
				dam=math.floor(rc:GetAttack())
				if c.Weakness and c.Weakness==TYPE_MONSTER then dam=rc:GetAttack()*2 end
				if c.Resist and c.Resist==TYPE_MONSTER then dam=rc:GetAttack() end
			end
			if rc:IsType(TYPE_SPELL) then
				dam=val*2
				if c.Weakness and c.Weakness==TYPE_SPELL then dam=val*4 end
				if c.Resist and c.Resist==TYPE_SPELL then dam=val end
			end
			if rc:IsType(TYPE_TRAP) then
				dam=val*2
				if c.Weakness and c.Weakness==TYPE_TRAP then dam=val*4 end
				if c.Resist and c.Resist==TYPE_TRAP then dam=val end
			end
			bossraid.DamageToWereWolf(c:GetHandler(),dam,REASON_EFFECT)
		end
		return true
	end
end
function bossraid.WerewolfDamop(e,tp,eg,ep,ev,re,r,rp)
	if ep==tp then
		bossraid.DamageToWereWolf(ep,ev,REASON_EFFECT)
	end
end
function bossraid.Failed(e,tp,eg,ep,ev,re,r,rp)
	local WIN_REASON_DESTINY_LEO=0x17
	if e:GetHandler().Werewolf_Hp<=0 then 
		Duel.Win(tp,WIN_REASON_DESTINY_LEO)
	end
end
function Card.IsBoss(c)
	local mt=_G["c"..c:GetCode()]
	return mt.Boss_Raid
end
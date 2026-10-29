CARDDATA_SETCODE=1
POS_FACEDOWN_DEFENCE=POS_FACEDOWN_DEFENSE
RACE_PSYCHO=RACE_PSYCHIC
HINTMSG_OPERATECARD=HINTMSG_RESOLVECARD
POS_FACEUP_DEFENCE=POS_FACEUP_DEFENSE
STATUS_TO_HAND_WITHOUT_CONFIRM=0
-- EDOPRO - Koishipro 호환성 맞춤용 유틸리티
-- Koishipro 및 기본 YGOCore의 함수 중, EDOPRO에서 사라진 함수 등을 추가하여 같은 오리카 팩의 호환성을 보충.

function Auxiliary.NonTuner(f,...)
	return Synchro.NonTuner(f,...)
end
function Auxiliary.Tuner(f,...)
	return	function(target,scard,sumtype,tp)
				return target:IsType(TYPE_TUNER) and (not f or f(target,a,b,c))
			end
end
function Auxiliary.IsMaterialListType(c,type)
	return c.material_type and type&c.material_type==type
end
function Auxiliary.MustMaterialCheck(v,tp,code)
	return true
end
function Auxiliary.AddSynchroProcedure(c,f1,f2,minc,maxc)
	if maxc==nil then maxc=99 end
	Synchro.AddProcedure(c,f1,1,1,f2,minc,maxc)
end
function Auxiliary.AddSynchroMixProcedure(c,f1,f2,f3,f4,minc,maxc,gc)
	if maxc==nil then maxc=99 end
	Synchro.AddProcedure(c,f1,1,1,f4,minc,maxc)
end
function Auxiliary.AddXyzProcedure(c,f,lv,ct,alterf,alterdesc,maxct,alterop)
	if not maxct then maxct=ct end
	Xyz.AddProcedure(c,f,lv,ct,alterf,alterdesc,maxct,alterop,mustbemat,exchk)
end
function Card.IsSynchroType(c,ty)
	return c:IsType(ty)
end

function Auxiliary.AddLinkProcedure(c,f,min,max,gf)
	if max==nil then max=c:GetLink() end
	Link.AddProcedure(c,f,min,max,specialchk,desc)
end
function Card.IsLinkRace(c,rc)
	return c:IsRace(rc)
end
function Card.IsLinkSetCard(c,sc)
	return c:IsSetCard(sc)
end
function Group.SelectSubGroup(g,tp,func,cancel,minc,maxc,...)
	local minc=minc or 1
	local maxc=maxc or #g
	local hintmsg=0
	local sg=Group.CreateGroup()
	while true do
		local finishable = #sg>=minc and (not func or func(sg,...))
		local mg=g:Filter(Auxiliary.SelectUnselectLoop,sg,sg,g,nil,tp,minc,maxc,nil,func(sg,...))
		if (breakcon and breakcon(sg,e,tp,mg)) or #mg<=0 or #sg>=maxc then break end
		Duel.Hint(HINT_SELECTMSG,tp,hintmsg)
		local tc=mg:SelectUnselect(sg,tp,finishable,finishable or (cancelable and #sg==0),minc,maxc)
		if not tc then break end
		if sg:IsContains(tc) then
			sg:RemoveCard(tc)
		else
			sg:AddCard(tc)
		end
	end
	return sg
end
function Auxiliary.dncheck(g)
	return g:GetClassCount(Card.GetCode)==#g
end
function Auxiliary.AddFusionProcCodeFun(c,code1,f,cc,sub,insf)
	return Fusion.AddProcCodeFun(c,code1,f,cc,sub,insf)
end
function Auxiliary.AddFusionProcFunFunRep(c,f1,f2,minc,maxc,insf)
	return Fusion.AddProcFunFunRep(c,f1,f2,minc,maxc,insf)
end
function Auxiliary.AddFusionProcFunRep(c,f,cc,insf)
	return Fusion.AddProcFunRep(c,f,cc,insf)
end
function Auxiliary.AddFusionProcFunFun(c,f1,f2,cc,insf)
	return Fusion.AddProcFunFun(c,f1,f2,cc,insf)
end
function Auxiliary.AddFusionProcMixRep(c,sub,insf,fun1,minc,maxc,...)
	return Fusion.AddProcMixRep(c,sub,insf,fun1,minc,maxc,...)
end
function Card.IsFusionSetCard(c,sc)
	return c:IsSetCard(sc)
end
function Card.IsFusionType(c,ty)
	return c:IsType(ty)
end
function Auxiliary.AddCodeList(c,...)
	if c:IsStatus(STATUS_COPYING_EFFECT) then return end
	if c.card_code_list==nil then
		local mt=getmetatable(c)
		mt.card_code_list={}
		for _,code in ipairs{...} do
			mt.card_code_list[code]=true
		end
	else
		for _,code in ipairs{...} do
			c.card_code_list[code]=true
		end
	end
end
function Auxiliary.EnableChangeCode(c,code,location,condition)
	Auxiliary.AddCodeList(c,code)
	local loc=c:GetOriginalType()&TYPE_MONSTER~=0 and LOCATION_MZONE or LOCATION_SZONE
	loc=location or loc
	if condition==nil then condition=Auxiliary.TRUE end
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetCode(EFFECT_CHANGE_CODE)
	e1:SetRange(loc)
	e1:SetCondition(condition)
	e1:SetValue(code)
	c:RegisterEffect(e1)
	return e1
end
function Auxiliary.EnableAddCode(c,code,location,condition)
	Auxiliary.AddCodeList(c,code)
	local loc=c:GetOriginalType()&TYPE_MONSTER~=0 and LOCATION_MZONE or LOCATION_SZONE
	loc=location or loc
	if condition==nil then condition=Auxiliary.TRUE end
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetCode(EFFECT_ADD_CODE)
	e1:SetRange(loc)
	e1:SetCondition(condition)
	e1:SetValue(code)
	c:RegisterEffect(e1)
	return e1
end
function Auxiliary.IsCodeListed(c,code)
	return c.card_code_list and c.card_code_list[code]
end
-- local cicfm=Card.IsCanBeFusionMaterial
-- function Card.IsCanBeFusionMaterial(c)
	-- if c:IsType(TYPE_SPELL+TYPE_TRAP) then return true end
	-- return cicfm(c)
-- end
function Auxiliary.EnableExtraDeckSummonCountLimit()
	if Auxiliary.ExtraDeckSummonCountLimit~=nil then return end
	Auxiliary.ExtraDeckSummonCountLimit={}
	Auxiliary.ExtraDeckSummonCountLimit[0]=1
	Auxiliary.ExtraDeckSummonCountLimit[1]=1
	local ge1=Effect.GlobalEffect()
	ge1:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	ge1:SetCode(EVENT_PHASE_START+PHASE_DRAW)
	ge1:SetOperation(Auxiliary.ExtraDeckSummonCountLimitReset)
	Duel.RegisterEffect(ge1,0)
end
function Auxiliary.ExtraDeckSummonCountLimitReset()
	Auxiliary.ExtraDeckSummonCountLimit[0]=1
	Auxiliary.ExtraDeckSummonCountLimit[1]=1
end
function Auxiliary.ExceptThisCard(e)
	return e:GetHandler()
end


function Duel.ReadCard(c,code)
	if code==CARDDATA_SETCODE then
		return c:GetSetCard()
	end
	return 0
end

function Duel.Exile(c,r)
	return function(e)
		Duel.Delete(e,c)
	end
end

function Auxiliary.dscon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetCurrentPhase()~=PHASE_DAMAGE or not Duel.IsDamageCalculated()
end
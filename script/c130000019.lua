--프리페어드 프리스티스
--Scripted by Cyan
local s,id=GetID()
function s.initial_effect(c)
	--페어링 소환
	cyan.AddPairingProcedure(c,s.pfilter,s.mfilter,2,2)
	c:EnableReviveLimit()
	--파괴 내성 부여
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_ONFIELD,0)
	e1:SetTarget(s.indtg)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	c:RegisterEffect(e2)	
	--파괴한 몬스터를 특수 소환
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetCode(EVENT_BATTLE_DESTROYING)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCondition(aux.bdogcon)
	e3:SetTarget(s.sptg)
	e3:SetOperation(s.spop)
	c:RegisterEffect(e3)
end
function s.pfilter(c)
	return c:GetSummonLocation()==LOCATION_EXTRA
end
function s.mfilter(c,pair)
	if pair:GetLevel()<=0 then return false end
	return c:GetLevel()+3==pair:GetLevel()
end
function s.indtg(e,c)
	local g=e:GetHandler():GetPair()
	return g:IsContains(c)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local pr=e:GetHandler():GetPair()
	local bc=e:GetHandler():GetBattleTarget()
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and bc:GetLevel()>=1
		and bc:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP) and pr:IsExists(Card.IsLevelAbove,1,nil,bc:GetLevel()+1) end
	Duel.SetTargetCard(bc)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,bc,1,0,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
	end
end
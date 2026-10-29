
-- 수렵


--공통 효과 처리
function YiPi.HunterCheck(c)
	local lv=c:GetLevel()
	if c:IsType(TYPE_XYZ) then lv=c:GetRank() end
	return lv>=8
end
function YiPi.IsHuntingTargetExists(p,sf,of)
	local m=0
	local o=0
	if sf==1 then m=LOCATION_MZONE end
	if of==1 then o=LOCATION_MZONE end
	return Duel.IsExistingMatchingCard(YiPi.HunterCheck,p,m,o,1,nil)
end
function YiPi.IsBackupExists(p)
	return Duel.IsExistingMatchingCard(YiPi.SpellHunterCheck,p,LOCATION_SZONE,0,1,nil)
end
function YiPi.SpellHunterCheck(c)
	return c:IsSetCard(SETCARD_HUNTER) and c:IsType(TYPE_SPELL) and c:IsType(TYPE_CONTINUOUS) and c:IsFaceup()
end
function YiPi.IsAbleToTag(c,e,tp)
	return c:IsCanBeSpecialSummoned(e,0,tp,tp,false,false)
		and Duel.IsExistingMatchingCard(YiPi.TagRelChk,tp,LOCATION_ONFIELD,0,1,nil,tp)
end
function YiPi.TagRelChk(c,tp)
	return c:IsSetCard(SETCARD_HUNTER) and c:IsFaceup() and c:IsReleasableByEffect()
		and Duel.GetLocationCount(tp,LOCATION_MZONE,c)>0
end
function YiPi.Tag(c,e,tp)
	if c:IsCanBeSpecialSummoned(e,0,tp,tp,false,false) then
		local g=Duel.SelectMatchingCard(tp,YiPi.TagRelChk,tp,LOCATION_ONFIELD,0,1,1,nil,tp)
		if g:GetCount()>0 then
			Duel.Release(g,REASON_EFFECT)
			Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end

function YiPi.HuntTarget(c)
	c:SetUniqueOnField(1,0,aux.FilterBoolFunction(Card.IsSetCard,SETCARD_HUNTTARGET),LOCATION_MZONE)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetCountLimit(1,id)
	e1:SetRange(LOCATION_HAND)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_SPSUM_PARAM)
	e1:SetTargetRange(POS_FACEUP,1)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetProperty(EFFECT_FLAG_CLIENT_HINT)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_CANNOT_CHANGE_POSITION)
	c:RegisterEffect(e2)
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_POSITION)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e3:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e3:SetCountLimit(1)
	e3:SetRange(LOCATION_MZONE)
	e3:SetOperation(YiPi.HuntTargetPos)
	c:RegisterEffect(e3)
end
function YiPi.HuntTargetPos(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFaceup() and c:IsRelateToEffect(e) then
		Duel.ChangePosition(c,POS_FACEUP_DEFENSE,POS_FACEUP_ATTACK,POS_FACEUP_ATTACK,POS_FACEUP_ATTACK)
	end
end
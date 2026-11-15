--밤하늘 색의 진노
local s,id=GetID()
function s.initial_effect(c)
	--소환된 몬스터 파괴
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
	c:RegisterEffect(e2)
	local e3=e1:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)	
end
function s.cfilter(c,rc)
	return c:IsFaceup() and c:IsRace(rc)
end
function s.filter(c,tp)
	return Duel.IsExistingMatchingCard(s.cfilter,tp,0,LOCATION_MZONE,1,nil,c:GetRace()) and c:IsControler(1-tp)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetCurrentChain(true)==0 and eg:IsExists(s.filter,1,nil,tp)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local g=eg:Filter(s.filter,nil)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,#g,0,0)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local g=eg:Filter(s.filter,nil)
	Duel.Destroy(g,REASON_EFFECT)
end
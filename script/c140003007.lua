--도와줘보든가
local s,id=GetID()
function s.initial_effect(c)
	--발동 효과
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DAMAGE+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_EXTRA)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end

--기프트 대상
function s.gfilter(c)
	return c:IsSetCard(0x301)
end
function s.desfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x301)
end

--발동 효과
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckGiftEffect(tp,s.gfilter) end
	Duel.SetTargetPlayer(1-tp)
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,1000)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	--1번 효과
	local b2=Duel.IsExistingMatchingCard(s.desfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil)
	local op=0
	if b2 then op=Duel.SelectOption(tp,aux.Stringid(id,1),aux.Stringid(id,2))
	else Duel.SelectOption(tp,aux.Stringid(id,1)) end
	if op==0 then
		Duel.Damage(1-tp,1000,REASON_EFFECT)
	else
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
		local g=Duel.SelectMatchingCard(tp,s.desfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
		Duel.HintSelection(g)
		if Duel.Destroy(g,REASON_EFFECT)>0 then
			Duel.Damage(1-tp,1500,REASON_EFFECT)
		end
	end
	--기프트 부여
	if Duel.CheckGiftEffect(tp,s.gfilter) then
		Duel.AddGiftEffect(e,s.gfilter,s.geffect,0,0)
	end
end

--기프트 효과
function s.geffect(e,c)
	--1번 효과
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DEFCHANGE)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e1:SetProperty(EFFECT_FLAG_CLIENT_HINT)
	e1:SetCode(EVENT_DESTROYED)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(s.gcon)
	e1:SetOperation(s.gop)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	c:RegisterEffect(e1)
end
function s.gconfilter(c)
	return c:IsReason(REASON_PAIR) and c:IsPreviousSetCard(0x301) and c:IsPreviousLocation(LOCATION_MZONE)
end
function s.gcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.gconfilter,1,nil)
end
function s.gop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsFaceup() or not c:IsRelateToEffect(e) then return end
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetValue(300)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e2)
end

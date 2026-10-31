--사라지는 불꽃 아주라이트
local s,id=GetID()
function s.initial_effect(c)
	--엑시즈 소환
	aux.AddXyzProcedure(c,nil,4,2,nil,nil,99)
	c:EnableReviveLimit()
	--소재 제거(효과 대상)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetCode(EVENT_BECOME_TARGET)
	e1:SetOperation(s.desop1)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EVENT_CHAIN_SOLVED)
	e2:SetOperation(s.desop2)
	e2:SetLabelObject(e1)
	c:RegisterEffect(e2)
	--소재 제거(전투 대상)
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_BE_BATTLE_TARGET)
	e3:SetOperation(s.desop3)
	c:RegisterEffect(e3)
	--소재 제거(스탠바이 페이즈)
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e4:SetCountLimit(1)
	e4:SetCondition(s.sbcon)
	e4:SetOperation(s.desop3)
	c:RegisterEffect(e4)
	--효과 완전 내성
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_SINGLE)
	e5:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e5:SetRange(LOCATION_MZONE)
	e5:SetCode(EFFECT_IMMUNE_EFFECT)
	e5:SetValue(s.efilter)
	c:RegisterEffect(e5)
	--엑시즈 소재로 한다
	local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_QUICK_O)
	e6:SetCode(EVENT_FREE_CHAIN)
	e6:SetRange(LOCATION_MZONE)
	e6:SetDescription(aux.Stringid(id,0))
	e6:SetCountLimit(1)
	e6:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e6:SetTarget(s.xtg)
	e6:SetOperation(s.xop)
	c:RegisterEffect(e6)
end
function s.sbcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetTurnPlayer()==tp
end
function s.desop1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsLocation(LOCATION_MZONE) and c:IsFaceup() then
		e:SetLabelObject(re)
		e:SetLabel(0)
	end
end
function s.desop2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if re==e:GetLabelObject():GetLabelObject() and c:IsRelateToEffect(re) and re:GetHandlerPlayer()==1-tp then
		if Duel.GetCurrentPhase()==PHASE_DAMAGE and not Duel.IsDamageCalculated() then
			e:GetLabelObject():SetLabel(1)
		else
			if c:IsHasEffect(EFFECT_DISABLE) then return end
			if not c:IsDisabled() then
				if e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) then
					e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
				else
					Duel.SendtoGrave(e:GetHandler(),REASON_COST)
				end
			end
		end
	end
end
function s.desop3(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsHasEffect(EFFECT_DISABLE) then return end
	if not c:IsDisabled() then
		if e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) then
			e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
		else
			Duel.SendtoGrave(e:GetHandler(),REASON_COST)
		end
	end
end
function s.efilter(e,re)
	return e:GetHandler():GetControler()~=re:GetHandler():GetControler()
end
function s.xtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsType(TYPE_XYZ) and chkc:IsLocation(LOCATION_MZONE) and chkc:IsFaceup()
		and chkc~=e:GetHandler() end
	if chk==0 then return Duel.IsExistingTarget(s.tgfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,e:GetHandler()) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	local g=Duel.SelectTarget(tp,s.tgfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,e:GetHandler())
	local tc=g:GetFirst()
	if tc:GetOverlayCount()==0 then
		e:SetCategory(CATEGORY_DESTROY)
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,tc,1,tp,LOCATION_MZONE)
	else
		e:SetCategory(0)
	end
end
function s.tgfilter(c)
	return c:IsType(TYPE_XYZ) and c:IsFaceup()
end
function s.xop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		local xg=tc:GetOverlayGroup()
		if xg:GetCount()>0 then
			if e:GetHandler():IsRelateToEffect(e) then
				xg=xg:Select(tp,1,1,nil)
				Duel.Overlay(e:GetHandler(),xg)
			end
		else
			Duel.Destroy(tc,REASON_EFFECT)
		end
	end
end

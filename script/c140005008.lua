--환영검성 재니스
local s,id=GetID()
function s.initial_effect(c)
	--액세스 소환
	cyan.AddAccessProcedure(c,aux.TRUE,aux.TRUE)
	c:EnableReviveLimit()
	--①: 환영검 장착 마법이 장착되었을 경우에 환영검 장착 마법 선언 및 생성
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_ANNOUNCE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_EQUIP)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.mkcon)
	e1:SetTarget(s.mktg)
	e1:SetOperation(s.mkop)
	c:RegisterEffect(e1)
	--②: 자신 필드의 일천의 환영검의 수 × 300 공격력 상승
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetValue(s.atkval)
	c:RegisterEffect(e2)
end
function s.eqfilter(c,ec)
	return c:IsSetCard(SETCARD_ILLUSIONSWORD) and c:IsType(TYPE_EQUIP) and c:GetEquipTarget()==ec
end
function s.mkcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.eqfilter,1,nil,e:GetHandler())
end
function s.mktg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CODE)
	local ac=Duel.AnnounceCard(tp,SETCARD_ILLUSIONSWORD,OPCODE_ISSETCARD,TYPE_EQUIP,OPCODE_ISTYPE,OPCODE_AND,TYPE_SPELL,OPCODE_ISTYPE,OPCODE_AND)
	Duel.SetTargetParam(ac)
	Duel.SetOperationInfo(0,CATEGORY_ANNOUNCE,nil,0,tp,0)
end
function s.mkop(e,tp,eg,ep,ev,re,r,rp)
	local ac=Duel.GetChainInfo(0,CHAININFO_TARGET_PARAM)
	if ac and ac>0 then
		local token=Duel.CreateToken(tp,ac)
		if Duel.SendtoHand(token,tp,REASON_EFFECT)>0 then
			Duel.ConfirmCards(1-tp,token)
		end
	end
end
function s.atkfilter(c)
	return c:IsFaceup() and c:IsCode(140005004)
end
function s.atkval(e,c)
	return Duel.GetMatchingGroupCount(s.atkfilter,c:GetControler(),LOCATION_ONFIELD,0,nil)*300
end

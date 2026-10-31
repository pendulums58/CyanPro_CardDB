--환영검성 에위니아
local s,id=GetID()
function s.initial_effect(c)
	--액세스 소환
	cyan.AddAccessProcedure(c,s.afil1,s.afil2)
	c:EnableReviveLimit()
	--①: 액세스 소환 성공 시 묘지의 환영검 카드 1장 회수
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetCondition(cyan.AccSSCon)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	--②: 패 1장 버리고 환영검 장착 마법 선언 및 생성
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_ANNOUNCE)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetCost(cyan.dhcost(1))
	e2:SetTarget(s.mktg)
	e2:SetOperation(s.mkop)
	c:RegisterEffect(e2)
end
function s.afil1(c)
	return c:GetEquipCount()>0
end
function s.afil2(c)
	return c:IsRace(RACE_WARRIOR)
end
function s.thfilter(c)
	return c:IsSetCard(SETCARD_ILLUSIONSWORD) and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and s.thfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.thfilter,tp,LOCATION_GRAVE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectTarget(tp,s.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
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

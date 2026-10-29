DOUBLE_SCRAPER=13151716

local dm=Debug.Message
local cregeff=Card.RegisterEffect
function Card.RegisterEffect(c,e,forced,...)
	local code=c:GetOriginalCode()
	local mt=_G["c"..code]
	cregeff(c,e,forced,...)	
	if code==63035430 and mt.eff_ct[c][1]==e then
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_FIELD)
		e2:SetCode(EFFECT_UPDATE_ATTACK)
		e2:SetRange(LOCATION_FZONE)
		e2:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
		e2:SetCondition(marui.atkcon)
		e2:SetTarget(marui.atktg)
		e2:SetValue(marui.atkval)
		cregeff(c,e2)
	end
	if code==47596607 and mt.eff_ct[c][1]==e then
		local e2=Effect.CreateEffect(c)
		e2:SetDescription(aux.Stringid(47596607,1))
		e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
		e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
		e2:SetType(EFFECT_TYPE_IGNITION)
		e2:SetRange(LOCATION_FZONE)
		e2:SetCountLimit(1)
		e2:SetTarget(marui.sptg)
		e2:SetOperation(marui.spop)
		cregeff(c,e2)
	end
	if code==40522482 then
		e:SetTarget(marui.target)
		e:SetOperation(marui.activate)
	end
end
--마천루-스카이스크레이퍼 수정
function marui.atkcon(e)
    return Duel.GetCurrentPhase()==PHASE_DAMAGE_CAL and Duel.GetAttackTarget()
end
function marui.atktg(e,c)
	local ctype=c:IsSetCard(0x3008)
	if Duel.IsPlayerAffectedByEffect(e:GetHandler():GetControler(),13151714) then
		ctype=(c:IsSetCard(0x3008) or c:IsSetCard(0x62c))
	end
	return c==Duel.GetAttacker() and ctype  
end
function marui.atkval(e,c)
	local atkup=1000
	local tp=c:GetControler()
	local g=Duel.GetMatchingGroup(Card.IsHasEffect,tp,LOCATION_GRAVE,0,nil,DOUBLE_SCRAPER)
	local tc=g:GetFirst()
	while tc do
		atkup=atkup+1000
		tc=g:GetNext()
	end
    local d=Duel.GetAttackTarget()
    if c:GetAttack()<d:GetAttack() then
		return atkup
    else return 0 end
end
--마천루2-히어로시티 수정
function marui.filter(c,e,tp)
	local ctype=c:IsSetCard(0x3008)
	if Duel.IsPlayerAffectedByEffect(e:GetHandler():GetControler(),13151714) then
		ctype=(c:IsSetCard(0x3008) or c:IsSetCard(0x62c))
	end
    return ctype and bit.band(c:GetReason(),REASON_BATTLE)~=0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function marui.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and marui.filter(chkc,e,tp) end
    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
        and Duel.IsExistingTarget(marui.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local g=Duel.SelectTarget(tp,marui.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
function marui.spop(e,tp,eg,ep,ev,re,r,rp)
    if not e:GetHandler():IsRelateToEffect(e) then return end
    local tc=Duel.GetFirstTarget()
    if tc:IsRelateToEffect(e) then
        Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
    end
end
--스카이스크레이퍼 슛 수정
function marui.sfilter(c,tp)
	local ctype=c:IsSetCard(0x3008)
	if Duel.IsPlayerAffectedByEffect(c:GetControler(),13151714) then
		ctype=(c:IsSetCard(0x3008) or c:IsSetCard(0x62c))
	end
    return c:IsFaceup() and ctype and c:IsType(TYPE_FUSION)
        and Duel.IsExistingMatchingCard(marui.desfilter,tp,0,LOCATION_MZONE,1,nil,c:GetAttack())
end
function marui.desfilter(c,atk)
    return c:IsFaceup() and c:GetAttack()>atk
end
function marui.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and marui.sfilter(chkc,tp) end
    if chk==0 then return Duel.IsExistingTarget(marui.sfilter,tp,LOCATION_MZONE,0,1,nil,tp) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
    local tg=Duel.SelectTarget(tp,marui.sfilter,tp,LOCATION_MZONE,0,1,1,nil,tp)
    local atk=tg:GetFirst():GetAttack()
    local g=Duel.GetMatchingGroup(marui.desfilter,tp,0,LOCATION_MZONE,nil,atk)
    Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
    local fc=Duel.GetFieldCard(tp,LOCATION_FZONE,0)
    local dam=0
    if fc and marui.ffilter(fc) then
        dam=g:GetSum(Card.GetBaseAttack)
    else
        g,dam=g:GetMaxGroup(Card.GetBaseAttack)
    end
    Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,1,1-tp,dam)
end
function marui.ffilter(c)
    return c:IsFaceup() and c:IsSetCard(0xf6)
end
function marui.activate(e,tp,eg,ep,ev,re,r,rp)
    local tc=Duel.GetFirstTarget()
    if not tc:IsRelateToEffect(e) or tc:IsFacedown() then return end
    local g=Duel.GetMatchingGroup(marui.desfilter,tp,0,LOCATION_MZONE,nil,tc:GetAttack())
    if g:GetCount()>0 and Duel.Destroy(g,REASON_EFFECT)>0 then
        local og=Duel.GetOperatedGroup():Filter(Card.IsLocation,nil,LOCATION_GRAVE)
        if og:GetCount()==0 then return end
        local fc=Duel.GetFieldCard(tp,LOCATION_FZONE,0)
        local dam=0
        if fc and marui.ffilter(fc) then
            dam=og:GetSum(Card.GetBaseAttack)
        else
            g,dam=og:GetMaxGroup(Card.GetBaseAttack)
        end
		if Duel.IsPlayerAffectedByEffect(e:GetHandler():GetControler(),13151714) then
			dam=0
		end
        Duel.Damage(1-tp,dam,REASON_EFFECT)
    end
end

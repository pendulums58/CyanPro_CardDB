--다크라이트 라이브러리언
local s,id=GetID()
function s.initial_effect(c)
--싱크로 소환
aux.AddSynchroProcedure(c,nil,nil,1)
c:EnableReviveLimit()
--①: 자신 필드의 몬스터 공격력 400 상승
local e1=Effect.CreateEffect(c)
e1:SetType(EFFECT_TYPE_FIELD)
e1:SetCode(EFFECT_UPDATE_ATTACK)
e1:SetRange(LOCATION_MZONE)
e1:SetTargetRange(LOCATION_MZONE,0)
e1:SetValue(400)
c:RegisterEffect(e1)
--②: 전투 / 효과로 필드에서 묘지로 보내졌을 경우, 이 턴에 묘지로 보내진 마법 카드 1장 회수
local e2=Effect.CreateEffect(c)
e2:SetCategory(CATEGORY_TOHAND)
e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
e2:SetCode(EVENT_TO_GRAVE)
e2:SetCondition(s.thcon)
e2:SetTarget(s.thtg)
e2:SetOperation(s.thop)
c:RegisterEffect(e2)
end
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
local c=e:GetHandler()
return c:IsPreviousLocation(LOCATION_ONFIELD) and c:IsReason(REASON_BATTLE+REASON_EFFECT)
end
function s.thfilter(c)
return c:IsType(TYPE_SPELL) and c:GetTurnID()==Duel.GetTurnCount() and not c:IsReason(REASON_RETURN) and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.thfilter(chkc) end
if chk==0 then return Duel.IsExistingTarget(s.thfilter,tp,LOCATION_GRAVE,0,1,nil) end
Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
local g=Duel.SelectTarget(tp,s.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
local tc=Duel.GetFirstTarget()
if tc and tc:IsRelateToEffect(e) and Duel.SendtoHand(tc,nil,REASON_EFFECT)>0 and tc:IsLocation(LOCATION_HAND) then
Duel.ConfirmCards(1-tp,tc)
local e1=Effect.CreateEffect(e:GetHandler())
e1:SetType(EFFECT_TYPE_FIELD)
e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
e1:SetCode(EFFECT_CANNOT_ACTIVATE)
e1:SetTargetRange(1,0)
e1:SetValue(s.aclimit)
e1:SetLabel(tc:GetCode())
e1:SetReset(RESET_PHASE+PHASE_END)
Duel.RegisterEffect(e1,tp)
end
end
function s.aclimit(e,re,tp)
return re:IsHasType(EFFECT_TYPE_ACTIVATE) and re:GetHandler():IsCode(e:GetLabel())
end

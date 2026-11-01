--?????? ???
local s,id=GetID()
function s.initial_effect(c)
--??? ??
cyan.AddAccessProcedure(c,aux.TRUE,aux.TRUE)
c:EnableReviveLimit()
--?: ??? ????? ???? ?? ?? / ??? ?? ??? 1? ?? ??
local e1=Effect.CreateEffect(c)
e1:SetDescription(aux.Stringid(id,0))
e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
e1:SetType(EFFECT_TYPE_IGNITION)
e1:SetRange(LOCATION_MZONE)
e1:SetCountLimit(1,id)
e1:SetTarget(s.sptg)
e1:SetOperation(s.spop)
c:RegisterEffect(e1)
--?: ???? ????? ?? ??? ?? 1? ?? ??
local e2=Effect.CreateEffect(c)
e2:SetDescription(aux.Stringid(id,1))
e2:SetCategory(CATEGORY_DESTROY)
e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
e2:SetCode(EVENT_DESTROYED)
e2:SetCondition(s.descon)
e2:SetTarget(s.destg)
e2:SetOperation(s.desop)
c:RegisterEffect(e2)
end
function s.spfilter(c,e,tp,ad)
return c:IsType(TYPE_MONSTER) and c:GetAttack()<ad:GetAttack()
and c:IsRace(ad:GetRace()) and c:IsAttribute(ad:GetAttribute())
and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
local ad=e:GetHandler():GetAdmin()
if chk==0 then return ad~=nil and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp,ad) end
Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
local c=e:GetHandler()
if not c:IsRelateToEffect(e) or c:IsFacedown() then return end
local ad=c:GetAdmin()
if not ad then return end
Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp,ad)
if #g>0 then
Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
end
end
function s.descon(e,tp,eg,ep,ev,re,r,rp)
return e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
if chkc then return chkc:IsOnField() end
if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
local g=Duel.SelectTarget(tp,aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
local tc=Duel.GetFirstTarget()
if tc and tc:IsRelateToEffect(e) then
Duel.Destroy(tc,REASON_EFFECT)
end
end

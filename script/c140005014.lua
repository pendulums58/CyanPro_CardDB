--??????? ???
local s,id=GetID()
function s.initial_effect(c)
--??? ??
cyan.AddAccessProcedure(c,aux.TRUE,aux.TRUE)
c:EnableReviveLimit()
--?: ???? ?? ??? ??? ?? ?? ?? ? ?? ???? 2500?? ??
local e1=Effect.CreateEffect(c)
e1:SetDescription(aux.Stringid(id,0))
e1:SetCategory(CATEGORY_ATKCHANGE)
e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
e1:SetProperty(EFFECT_FLAG_DELAY)
e1:SetCode(EVENT_SPSUMMON_SUCCESS)
e1:SetRange(LOCATION_MZONE)
e1:SetCondition(s.atkcon)
e1:SetOperation(s.atkop)
c:RegisterEffect(e1)
--?: ??? ???? ?? ???? ??? ??? ?? ????? ???
local e2=Effect.CreateEffect(c)
e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
e2:SetCode(EVENT_BATTLE_START)
e2:SetCondition(s.discon)
e2:SetOperation(s.disop)
c:RegisterEffect(e2)
end
function s.cfilter(c,attr)
return c:IsFaceup() and (c:GetAttribute()&attr)~=0
end
function s.atkcon(e,tp,eg,ep,ev,re,r,rp)
local c=e:GetHandler()
local ad=c:GetAdmin()
if not ad then return false end
return eg:IsExists(s.cfilter,1,nil,ad:GetAttribute())
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
local c=e:GetHandler()
if c:IsRelateToEffect(e) and c:IsFaceup() then
local e1=Effect.CreateEffect(c)
e1:SetType(EFFECT_TYPE_SINGLE)
e1:SetCode(EFFECT_SET_BASE_ATTACK)
e1:SetValue(2500)
e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
c:RegisterEffect(e1)
end
end
function s.discon(e,tp,eg,ep,ev,re,r,rp)
local tc=e:GetHandler():GetBattleTarget()
return tc and tc:IsControler(1-tp) and tc:IsFaceup()
end
function s.disop(e,tp,eg,ep,ev,re,r,rp)
local c=e:GetHandler()
local tc=c:GetBattleTarget()
if not tc then return end
local e1=Effect.CreateEffect(c)
e1:SetType(EFFECT_TYPE_SINGLE)
e1:SetCode(EFFECT_DISABLE)
e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_DAMAGE)
tc:RegisterEffect(e1)
local e2=Effect.CreateEffect(c)
e2:SetType(EFFECT_TYPE_SINGLE)
e2:SetCode(EFFECT_DISABLE_EFFECT)
e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_DAMAGE)
tc:RegisterEffect(e2)
end

--파스텔윙 썬더버드
local s,id=GetID()
function s.initial_effect(c)
--싱크로 소환
aux.AddSynchroProcedure(c,nil,nil,1)
c:EnableReviveLimit()
--①: 묘지의 튜너 수 × 300 공격력 상승
local e1=Effect.CreateEffect(c)
e1:SetType(EFFECT_TYPE_SINGLE)
e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
e1:SetRange(LOCATION_MZONE)
e1:SetCode(EFFECT_UPDATE_ATTACK)
e1:SetValue(s.atkval)
c:RegisterEffect(e1)
--②: 레벨 4 이하 몬스터와 전투를 실행하는 공격 선언시 파괴
local e2=Effect.CreateEffect(c)
e2:SetCategory(CATEGORY_DESTROY)
e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
e2:SetCode(EVENT_ATTACK_ANNOUNCE)
e2:SetRange(LOCATION_MZONE)
e2:SetCountLimit(1)
e2:SetCondition(s.descon)
e2:SetTarget(s.destg)
e2:SetOperation(s.desop)
c:RegisterEffect(e2)
end
function s.atkval(e,c)
return Duel.GetMatchingGroupCount(Card.IsType,c:GetControler(),LOCATION_GRAVE,0,nil,TYPE_TUNER)*300
end
function s.descon(e,tp,eg,ep,ev,re,r,rp)
local bc=e:GetHandler():GetBattleTarget()
return bc and bc:IsFaceup() and bc:IsLevelBelow(4)
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
local bc=e:GetHandler():GetBattleTarget()
if chk==0 then return bc~=nil end
Duel.SetOperationInfo(0,CATEGORY_DESTROY,bc,1,0,0)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
local bc=e:GetHandler():GetBattleTarget()
if bc and bc:IsRelateToBattle() then
Duel.Destroy(bc,REASON_EFFECT)
end
end

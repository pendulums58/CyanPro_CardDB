--슬픔에 잠긴 시스투스
local s,id=GetID()
function s.initial_effect(c)
--①: 선택 파괴 (조건 만족 시 양쪽 적용 가능)
local e1=Effect.CreateEffect(c)
e1:SetCategory(CATEGORY_DESTROY)
e1:SetType(EFFECT_TYPE_ACTIVATE)
e1:SetCode(EVENT_FREE_CHAIN)
e1:SetTarget(s.target)
e1:SetOperation(s.activate)
c:RegisterEffect(e1)
end
function s.bothfilter(c)
return c:IsSummonLocation(LOCATION_EXTRA) or (c:IsFaceup() and c:IsType(TYPE_KEY))
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
local c=e:GetHandler()
local b1=Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)>0
and Duel.IsExistingMatchingCard(Card.IsType,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,c,TYPE_SPELL+TYPE_TRAP)
local b2=Duel.GetFieldGroupCount(tp,0,LOCATION_SZONE)>0
and Duel.IsExistingMatchingCard(aux.TRUE,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil)
if chk==0 then return b1 or b2 end
local both=b1 and b2 and Duel.IsExistingMatchingCard(s.bothfilter,tp,0,LOCATION_MZONE,1,nil)
local op=0
if b1 and b2 and both then
op=Duel.SelectOption(tp,aux.Stringid(id,0),aux.Stringid(id,1),aux.Stringid(id,2))
elseif b1 and b2 then
op=Duel.SelectOption(tp,aux.Stringid(id,0),aux.Stringid(id,1))
elseif b1 then
op=Duel.SelectOption(tp,aux.Stringid(id,0))
else
op=Duel.SelectOption(tp,aux.Stringid(id,1))+1
end
e:SetLabel(op)
local dg=Group.CreateGroup()
local ct=0
if op==0 or op==2 then
local g1=Duel.GetMatchingGroup(Card.IsType,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,c,TYPE_SPELL+TYPE_TRAP)
dg:Merge(g1)
ct=ct+1
end
if op==1 or op==2 then
local g2=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
dg:Merge(g2)
ct=ct+1
end
Duel.SetOperationInfo(0,CATEGORY_DESTROY,dg,ct,0,0)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
local c=e:GetHandler()
local op=e:GetLabel()
local res=false
if (op==0 or op==2) and Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)>0 then
Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
local g1=Duel.SelectMatchingCard(tp,Card.IsType,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,c,TYPE_SPELL+TYPE_TRAP)
if #g1>0 then
Duel.HintSelection(g1)
if Duel.Destroy(g1,REASON_EFFECT)>0 then res=true end
end
end
if (op==1 or op==2) and Duel.GetFieldGroupCount(tp,0,LOCATION_SZONE)>0 then
if res then Duel.BreakEffect() end
Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
local g2=Duel.SelectMatchingCard(tp,aux.TRUE,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
if #g2>0 then
Duel.HintSelection(g2)
Duel.Destroy(g2,REASON_EFFECT)
end
end
end

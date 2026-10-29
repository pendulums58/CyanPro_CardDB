--Green.lua_ver 2022/04/10_19:51


green=green or {}
Green=green

local cregeff=Card.RegisterEffect
function Card.RegisterEffect(c,e,forced,...)
    local code=c:GetOriginalCode()
    local mt=_G["c"..code]
    cregeff(c,e,forced,...)
    --긴급 동조
    if code==94634433 and mt.eff_ct[c][0]==e then
        e:SetCondition(green.utcon)
    end
end
function green.utcon(e,tp,eg,ep,ev,re,r,rp)
    return (Duel.GetCurrentPhase()>=PHASE_BATTLE_START and Duel.GetCurrentPhase()<=PHASE_BATTLE)
        or (Duel.IsPlayerAffectedByEffect(tp,94634433) and Duel.GetTurnPlayer()==1-tp 
            and (Duel.GetCurrentPhase()==PHASE_MAIN1 
            or Duel.GetCurrentPhase()==PHASE_MAIN2))
end
function green.uthm(e,tp,eg,ep,ev,re,r,rp)
    return 
end
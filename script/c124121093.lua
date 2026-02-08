--개흑룡-레드아이즈 엣지
local s,id=GetID()
function s.initial_effect(c)
    -- 링크 소환 조건: "붉은 눈" 몬스터를 포함하는 몬스터 2장
    c:EnableReviveLimit()
    Link.AddProcedure(c,nil,2,2,s.matcheck)

    ----------------------------------------------------------
    -- ①: 묘지 / 제외의 "붉은 눈" 카드 1장 회수 + 이 카드를 EP까지 제외
    --    "이 카드를 엔드 페이즈까지 제외하고, 그 카드를 패에 넣는다."
    ----------------------------------------------------------
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_REMOVE+CATEGORY_TOHAND)
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetRange(LOCATION_MZONE)
    e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e1:SetCountLimit(1,id)
    e1:SetTarget(s.thtg)
    e1:SetOperation(s.thop)
    c:RegisterEffect(e1)

    ----------------------------------------------------------
    -- ②: 공격 선언시 400 데미지
    ----------------------------------------------------------
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,2))
    e2:SetCategory(CATEGORY_DAMAGE)
    e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
    e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    e2:SetCode(EVENT_ATTACK_ANNOUNCE)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCondition(s.dmgcon)
    e2:SetTarget(s.dmgtg)
    e2:SetOperation(s.dmgop)
    c:RegisterEffect(e2)

    ----------------------------------------------------------
    -- ③: 레드아이즈 몬스터 효과 발동 시, 상대 묘지 제외 + ATK +800
    ----------------------------------------------------------
    local e3=Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e3:SetCode(EVENT_CHAINING)
    e3:SetRange(LOCATION_MZONE)
    e3:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
    e3:SetCategory(CATEGORY_REMOVE+CATEGORY_ATKCHANGE)
    e3:SetCountLimit(1,{id,1})
    e3:SetCondition(s.con3)
    e3:SetTarget(s.tar3)
    e3:SetOperation(s.op3)
    c:RegisterEffect(e3)
end
s.listed_series={0x3b}

----------------------------------------------------------
-- 링크 소재 체크: 반드시 레드아이즈(0x3b) 몬스터 1장 포함
----------------------------------------------------------
function s.matcheck(g,lc,sumtype,tp)
    return g:IsExists(Card.IsSetCard,1,nil,0x3b,lc,sumtype,tp)
end

----------------------------------------------------------
-- ① 관련: "붉은 눈" 회수 + 이 카드 일시 제외
----------------------------------------------------------
function s.thfilter(c)
    return c:IsSetCard(0x3b) and c:IsFaceup() and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    local c=e:GetHandler()
    if chkc then
        return chkc:IsControler(tp)
            and chkc:IsLocation(LOCATION_GRAVE|LOCATION_REMOVED)
            and s.thfilter(chkc)
    end
    if chk==0 then
        -- 이 카드가 제외 가능해야 하고, 회수할 레드아이즈 카드도 있어야 함
        return c:IsAbleToRemove()
            and Duel.IsExistingTarget(s.thfilter,tp,LOCATION_GRAVE|LOCATION_REMOVED,0,1,nil)
    end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
    local g=Duel.SelectTarget(tp,s.thfilter,tp,LOCATION_GRAVE|LOCATION_REMOVED,0,1,1,nil)
    Duel.SetOperationInfo(0,CATEGORY_REMOVE,c,1,tp,0)
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,tp,0)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local tc=Duel.GetFirstTarget()
    -- 이 카드가 효과에 남아 있고, 일시 제외가 성공했을 때만 계속
    if c:IsRelateToEffect(e)
        and aux.RemoveUntil(c,nil,REASON_EFFECT,PHASE_END,id,e,tp,aux.DefaultFieldReturnOp)
        and tc and tc:IsRelateToEffect(e)
    then
        Duel.SendtoHand(tc,tp,REASON_EFFECT)
    end
end

----------------------------------------------------------
-- ②: 공격 선언시 400 데미지
----------------------------------------------------------
function s.dmgcon(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    return c:IsFaceup() and c:IsRelateToBattle()
end
function s.dmgtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SetTargetPlayer(1-tp)
    Duel.SetTargetParam(400)
    Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,400)
end
function s.dmgop(e,tp,eg,ep,ev,re,r,rp)
    local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
    Duel.Damage(p,d,REASON_EFFECT)
end

----------------------------------------------------------
-- ③: 레드아이즈 몬스터 효과 발동 트리거
----------------------------------------------------------
function s.con3(e,tp,eg,ep,ev,re,r,rp)
    local rc=re:GetHandler()
    return rc:IsSetCard(0x3b) and re:IsActiveType(TYPE_MONSTER)
end
function s.tar3(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then
        return chkc:IsLocation(LOCATION_GRAVE)
            and chkc:IsControler(1-tp)
            and chkc:IsAbleToRemove()
    end
    if chk==0 then
        return Duel.IsExistingTarget(Card.IsAbleToRemove,tp,0,LOCATION_GRAVE,1,nil)
    end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
    local g=Duel.SelectTarget(tp,Card.IsAbleToRemove,tp,0,LOCATION_GRAVE,1,1,nil)
    Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
end
function s.op3(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local tc=Duel.GetFirstTarget()
    if tc:IsRelateToEffect(e)
        and Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)>0
        and c:IsRelateToEffect(e)
        and c:IsFaceup() then
        local e1=Effect.CreateEffect(c)
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_UPDATE_ATTACK)
        e1:SetReset(RESET_EVENT+RESETS_STANDARD)
        e1:SetValue(800)
        c:RegisterEffect(e1)
    end
end
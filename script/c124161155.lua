--휴프알로 녹티스
local s,id=GetID()
function s.initial_effect(c)
	--effect 1
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCost(Cost.SelfReveal)
	e1:SetTarget(s.tg1)
	e1:SetOperation(s.op1)
	c:RegisterEffect(e1)
	--effect 2
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_POSITION)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,{id,1})
	e2:SetTarget(s.tg2)
	e2:SetOperation(s.op2)
	c:RegisterEffect(e2)
end

--effect 1
function s.tg1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
end

function s.op1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SUMMON_PROC)
	e1:SetTargetRange(LOCATION_HAND,0)
	e1:SetCondition(s.ntcon)
	e1:SetTarget(aux.FieldSummonProcTg(s.nttg))
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
end

function s.ntcon(e,c,minc)
	if c==nil then return true end
	return minc==0 and Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
end
function s.nttg(e,c)
	return c:IsSetCard(0xf2a) and c:IsLevelAbove(5)
end

--effect 2
function s.tg2ffilter(c,cd)
	return c:IsSetCard(0xf2a) and c:IsMonster() and not c:IsCode(cd) and c:IsAbleToHand()
end

function s.tg2filter(c,e,tp)
	return c:IsFaceup() and c:IsSetCard(0xf2a) and c:IsCanBeEffectTarget(e) and Duel.GetMatchingGroupCount(s.tg2ffilter,tp,LOCATION_DECK,0,nil,c:GetCode())>0 and c:IsCanTurnSet()
end

function s.tg2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.tg2filter(chkc,e,tp) end
	local g=Duel.GetMatchingGroup(s.tg2filter,tp,LOCATION_MZONE,0,nil,e,tp)
	if chk==0 then return #g>0 end
	local sg=aux.SelectUnselectGroup(g,e,tp,1,1,aux.TRUE,1,tp,HINTMSG_POSCHANGE)
	Duel.SetTargetCard(sg)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	Duel.SetOperationInfo(0,CATEGORY_POSITION,sg,#sg,0,0)
end

function s.op2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tg=Duel.GetTargetCards(e):GetFirst()
	if tg and tg:IsFaceup() then  
		local g=Duel.GetMatchingGroup(s.tg2ffilter,tp,LOCATION_DECK,0,nil,tg:GetCode())
		if #g>0 then
			local sg=aux.SelectUnselectGroup(g,e,tp,1,1,aux.TRUE,1,tp,HINTMSG_ATOHAND)
			Duel.SendtoHand(sg,nil,REASON_EFFECT)
			Duel.ConfirmCards(1-tp,sg)
			Duel.ChangePosition(tg,POS_FACEDOWN_DEFENSE) 
		end
	end
end

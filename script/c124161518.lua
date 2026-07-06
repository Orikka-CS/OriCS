--페를라렌트 러스트
local s,id=GetID()
function s.initial_effect(c)
	--effect 1
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN+CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.tg1)
	e1:SetOperation(s.op1)
	c:RegisterEffect(e1)
	--effect 2
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_DISABLE)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCost(Cost.SelfBanish)
	e2:SetTarget(s.tg2)
	e2:SetOperation(s.op2)
	c:RegisterEffect(e2)
end

--effect 1
function s.tg1filter(c)
	return c:IsSetCard(0xf41) and not c:IsCode(id) and c:IsAbleToHand()
end

function s.tg1(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(s.tg1filter,tp,LOCATION_DECK,0,nil)
	if chk==0 then return #g>0 end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	Duel.SetPossibleOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,0)
	Duel.SetPossibleOperationInfo(0,CATEGORY_EQUIP,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end

function s.op1eqfilter(c,tp,tc)
	return c:IsSpell() and c:IsType(TYPE_EQUIP) and c:CheckEquipTarget(tc) and c:CheckUniqueOnField(tp)
end

function s.op1tgfilter(c,e,tp)
	return c:IsFaceup() and Duel.GetMatchingGroupCount(s.op1eqfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,nil,tp,c)>0
end

function s.op1(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.tg1filter,tp,LOCATION_DECK,0,nil)
	if #g>0 then
		local sg=aux.SelectUnselectGroup(g,e,tp,1,1,aux.TRUE,1,tp,HINTMSG_ATOHAND)
		if Duel.SendtoHand(sg,nil,REASON_EFFECT)>0 then
			Duel.ConfirmCards(1-tp,sg)
			Duel.ShuffleDeck(tp)
			if Duel.GetLocationCount(1-tp,LOCATION_MZONE)>0 and Duel.GetLocationCount(tp,LOCATION_SZONE)>0 and Duel.IsPlayerCanSpecialSummonMonster(tp,124161508,0xf41,TYPES_TOKEN,700,700,2,RACE_ZOMBIE,ATTRIBUTE_DARK,POS_FACEUP,1-tp) and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
				Duel.BreakEffect()
				local token=Duel.CreateToken(tp,124161508)
				if Duel.SpecialSummon(token,0,tp,1-tp,false,false,POS_FACEUP)>0 then
					local mg=Duel.GetMatchingGroup(s.op1tgfilter,tp,0,LOCATION_MZONE,nil,e,tp)
					if #mg>0 then
						Duel.BreakEffect()
						local tc=aux.SelectUnselectGroup(mg,e,tp,1,1,aux.TRUE,1,tp,HINTMSG_EQUIP):GetFirst()
						local eg=Duel.GetMatchingGroup(s.op1eqfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,nil,tp,tc)
						if #eg>0 and Duel.GetLocationCount(tp,LOCATION_SZONE)>0 then
							local esc=aux.SelectUnselectGroup(eg,e,tp,1,1,aux.TRUE,1,tp,HINTMSG_EQUIP):GetFirst()
							Duel.Equip(tp,esc,tc)
						end
					end
				end
			end
		end
	end
end

--effect 2
function s.tg2filter(c)
	return c:IsFaceup() and c:GetEquipCount()>0 and c:IsNegatable()
end

function s.tg2(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(s.tg2filter,tp,0,LOCATION_MZONE,nil)
	if chk==0 then return #g>0 end
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,g,#g,0,0)
end

function s.op2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=Duel.GetMatchingGroup(s.tg2filter,tp,0,LOCATION_MZONE,nil)
	if #g>0 then
		for tc in g:Iter() do
			tc:NegateEffects(c,RESET_PHASE+PHASE_END,true)
		end
	end
end
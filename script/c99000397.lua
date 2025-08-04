--루네크로워커 미스트리아
local s,id=GetID()
function s.initial_effect(c)
	--fusion material
	Fusion.AddProcMix(c,true,true,aux.FilterBoolFunctionEx(Card.IsSetCard,0xc24),aux.FilterBoolFunctionEx(Card.IsAttribute,ATTRIBUTE_DARK))
	Fusion.AddContactProc(c,s.contactfil,s.contactop,s.splimit)
	c:EnableReviveLimit()
	--그 몬스터의 컨트롤을 엔드 페이즈까지 얻는다.
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_CONTROL)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetCondition(function(e) return e:GetHandler():IsSummonLocation(LOCATION_EXTRA) end)
	e1:SetTarget(s.cttg)
	e1:SetOperation(s.ctop)
	c:RegisterEffect(e1)
	--이 카드를 뒷면 수비 표시로 한다(1턴에 1번만).
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_POSITION)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTarget(s.postg)
	e2:SetOperation(s.posop)
	c:RegisterEffect(e2)
end
s.listed_series={0xc24}
function s.contactfil(tp)
	return Duel.GetMatchingGroup(aux.AND(Card.IsMonster,Card.IsAbleToRemoveAsCost),tp,LOCATION_ONFIELD|LOCATION_GRAVE,0,nil)
end
function s.contactop(g)
	Duel.Remove(g,POS_FACEUP,REASON_COST|REASON_MATERIAL)
end
function s.splimit(e,se,sp,st)
	return e:GetHandler():GetLocation()~=LOCATION_EXTRA
end
function s.cttg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsAbleToChangeControler() and chkc:IsLocation(LOCATION_MZONE) end
	if chk==0 then return ft>0 and Duel.IsExistingTarget(Card.IsAbleToChangeControler,tp,0,LOCATION_MZONE,1,nil) end
	local ct=math.min(ft,2)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)
	local g=Duel.SelectTarget(tp,Card.IsAbleToChangeControler,tp,0,LOCATION_MZONE,1,ct,nil)
	Duel.SetOperationInfo(0,CATEGORY_CONTROL,g,#g,0,0)
end
function s.ctop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	--이 효과의 발동 후, 턴 종료시까지 자신은 언데드족 몬스터로밖에 공격 선언할 수 없다.
	local ge1=Effect.CreateEffect(c)
	ge1:SetType(EFFECT_TYPE_FIELD)
	ge1:SetCode(EFFECT_CANNOT_ATTACK_ANNOUNCE)
	ge1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	ge1:SetTargetRange(LOCATION_MZONE,0)
	ge1:SetTarget(s.atktg)
	ge1:SetReset(RESET_PHASE|PHASE_END)
	Duel.RegisterEffect(ge1,tp)
	--client hint
	aux.RegisterClientHint(e:GetHandler(),nil,tp,1,0,aux.Stringid(id,2),nil)
	local tg=Duel.GetTargetCards(e)
	if #tg>0 and Duel.GetControl(tg,tp,PHASE_END,1) then
		local og=Duel.GetOperatedGroup()
		if #og==0 then return end
		for tc in og:Iter() do
			tc:NegateEffects(c,RESET_CONTROL)
		end
	end
end
function s.atktg(e,c)
	return not c:IsRace(RACE_ZOMBIE)
end
function s.postg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsCanTurnSet() and c:GetFlagEffect(id)==0 end
	c:RegisterFlagEffect(id,RESET_EVENT|RESETS_STANDARD-RESET_TURN_SET|RESET_PHASE|PHASE_END,0,1)
	Duel.SetOperationInfo(0,CATEGORY_POSITION,c,1,0,0)
end
function s.posop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) or not c:IsFaceup() then return end
	Duel.ChangePosition(c,POS_FACEDOWN_DEFENSE)
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,0,nil)
	if #g>0 then
		Duel.BreakEffect()
		for tc in g:Iter() do
			--그 몬스터들은 턴 종료시까지 언데드족이 되고, "네크로워커" 몬스터로도 취급한다.
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_CHANGE_RACE)
			e1:SetValue(RACE_ZOMBIE)
			e1:SetReset(RESETS_STANDARD_PHASE_END)
			tc:RegisterEffect(e1)
			local e2=Effect.CreateEffect(e:GetHandler())
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetCode(EFFECT_ADD_SETCODE)
			e2:SetValue(0xc24)
			e2:SetReset(RESETS_STANDARD_PHASE_END)
			tc:RegisterEffect(e2)
		end
	end
end
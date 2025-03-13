--[ Aranea ]
local s,id=GetID()
function s.initial_effect(c)

	c:EnableReviveLimit()
	Fusion.AddProcMixRep(c,true,true,s.mat,2,99,s.mat2)
	Fusion.AddContactProc(c,s.contactfil,s.contactop,s.splimit,s.contactcon)
	
	local e99=MakeEff(c,"FTf","M")
	e99:SetD(id,1)
	e99:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DEFCHANGE)
	e99:SetCode(EVENT_PHASE+PHASE_END)
	e99:SetCL(1)
	e99:SetOperation(s.op99)
	c:RegisterEffect(e99)
	
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(0,LOCATION_MZONE)
	e1:SetValue(s.val)
	c:RegisterEffect(e1)
	
	local e2=MakeEff(c,"Qo","M")
	e2:SetD(id,0)
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SPECIAL_SUMMON)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCL(1)
	WriteEff(e2,2,"TO")
	c:RegisterEffect(e2)
	
end

function s.mat(c,fc,sumtype,tp)
	return (math.abs(c:GetAttack()-c:GetBaseAttack())>=700 or (not c:IsType(TYPE_LINK) and math.abs(c:GetDefense()-c:GetBaseDefense())>=700))
		and c:IsLocation(LOCATION_MZONE) and (c:IsControler(tp) or c:IsFaceup())
end
function s.mat2(c,fc,sumtype,tp)
	return c:IsSetCard(0x3d71) and c:IsType(TYPE_TUNER)
		and c:IsLocation(LOCATION_MZONE) and (c:IsControler(tp) or c:IsFaceup())
end
function s.contactop(g,tp,c)
	Duel.RegisterFlagEffect(tp,id,RESET_PHASE|PHASE_END,EFFECT_FLAG_OATH,1)
	Duel.SendtoGrave(g,REASON_COST|REASON_MATERIAL)
end
function s.splimit(e,se,sp,st)
	return e:GetHandler():GetLocation()~=LOCATION_EXTRA
end
function s.cfilter(c,tp)
	return c:IsAbleToGraveAsCost() and (c:IsControler(tp) or c:IsFaceup())
end
function s.contactfil(tp)
	return Duel.GetMatchingGroup(s.cfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil,tp)
end
function s.contactcon(tp)
	return not Duel.HasFlagEffect(tp,id)
end

function Card.IsAraneaFood(c,def)
	return c:GetAttack()<def or (c:GetDefense()<def and not c:IsType(TYPE_LINK))
end

function s.op99(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_DEFENSE)
		e1:SetValue(200)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD_DISABLE)
		c:RegisterEffect(e1)
	end
	local g=Duel.GetMatchingGroup(Card.IsAraneaFood,tp,0,LOCATION_MZONE,nil,c:GetDefense())
	if #g>0 then
		for tc in g:Iter() do
			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetCode(EFFECT_SET_ATTACK_FINAL)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD)
			e2:SetValue(0)
			tc:RegisterEffect(e2)
			local e3=e2:Clone()
			e3:SetCode(EFFECT_SET_DEFENSE_FINAL)
			tc:RegisterEffect(e3)
		end
	end
end

function s.valfilter(c,att)
	return c:IsAttribute(att) and (c:IsFaceup() or c:IsLocation(LOCATION_GRAVE)) and c:IsRace(RACE_INSECT)
end
function s.val(e,c)
	local atk=0
	if Duel.IsExistingMatchingCard(s.valfilter,e:GetHandlerPlayer(),LOCATION_MZONE+LOCATION_GRAVE,0,1,nil,c:GetAttribute()) then
		atk=-1000 end
	return atk
end

function s.tar2fil(c,e,tp,tuner)
	return c:IsSetCard(0x3d71) and c:IsType(TYPE_MONSTER)
		and (c:IsAbleToHand() or (tuner and IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP)))
end
function s.tar2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local tuner=e:GetHandler():IsType(TYPE_TUNER) and e:GetHandler():IsFaceup()
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and s.tar2fil(chkc,e,tp,tuner) end
	if chk==0 then return Duel.IsExistingTarget(s.tar2fil,tp,LOCATION_GRAVE,0,1,nil,e,tp,tuner) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectTarget(tp,s.tar2fil,tp,LOCATION_GRAVE,0,1,1,nil,e,tp,tuner)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,LOCATION_GRAVE)
	Duel.SetPossibleOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end
function s.op2(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		if not e:GetHandler():IsType(TYPE_TUNER) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			and tc:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP)
			and (not tc:IsAbleToHand() or Duel.SelectYesNo(tp,aux.Stringid(id,2))) then
			Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
		else
			Duel.SendtoHand(tc,nil,REASON_EFFECT)
		end
	end
end

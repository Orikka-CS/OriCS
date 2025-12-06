--허월상의 명경 카날리
local s,id=GetID()
function s.initial_effect(c)
	--fusion
	c:EnableReviveLimit()
	Fusion.AddProcMix(c,true,true,aux.FilterBoolFunctionEx(Card.IsSetCard,0xf34),aux.FilterBoolFunctionEx(Card.IsAttribute,ATTRIBUTE_LIGHT),aux.FilterBoolFunctionEx(Card.IsRace,RACE_AQUA))
	--effect 1
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_ANNOUNCE)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.con1)
	e1:SetTarget(s.tg1)
	e1:SetOperation(s.op1)
	c:RegisterEffect(e1)
	--effect 2
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCondition(s.con2)
	e2:SetTarget(s.tg2)
	e2:SetOperation(s.op2)
	c:RegisterEffect(e2)
end

--effect 1
function s.con1ctfilter(c,e,tp,fusc,mg)
	return c:IsControler(tp) and c:IsLocation(LOCATION_GRAVE)
		and (c:GetReason()&(REASON_FUSION+REASON_MATERIAL))==(REASON_FUSION+REASON_MATERIAL) and c:GetReasonCard()==fusc and fusc:CheckFusionMaterial(mg,c,PLAYER_NONE+FUSPROC_NOTFUSION)
end


function s.con1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsSummonType(SUMMON_TYPE_FUSION) then return false end
	local mg=c:GetMaterial()
	local ct=mg:FilterCount(s.con1ctfilter,nil,e,tp,c,mg)
	return #mg>ct
end

function s.tg1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
end

function s.op1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsSummonType(SUMMON_TYPE_FUSION) then return false end
	local mg=c:GetMaterial()
	local ct=#mg-mg:FilterCount(s.con1ctfilter,nil,e,tp,c,mg)
	if ct>0 then
		local ac1=Duel.AnnounceCard(tp,TYPE_MONSTER,OPCODE_ISTYPE)
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e1:SetCode(EFFECT_CANNOT_ACTIVATE)
		e1:SetTargetRange(0,1)
		e1:SetValue(function(_e,_re,_tp) return _re:GetHandler():IsCode(ac1) and _re:IsMonsterEffect() and _re:GetActivateLocation()==LOCATION_MZONE end)
		e1:SetReset(RESET_PHASE+PHASE_END)
		Duel.RegisterEffect(e1,tp)
	end
	if ct>1 then
		local ac2=Duel.AnnounceCard(tp,TYPE_MONSTER,OPCODE_ISTYPE)
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_FIELD)
		e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e2:SetCode(EFFECT_CANNOT_ACTIVATE)
		e2:SetTargetRange(0,1)
		e2:SetValue(function(_e,_re,_tp) return _re:GetHandler():IsCode(ac2) and _re:IsMonsterEffect() and _re:GetActivateLocation()==LOCATION_MZONE end)
		e2:SetReset(RESET_PHASE+PHASE_END)
		Duel.RegisterEffect(e2,tp)
	end
	if ct>2 then
		local ac3=Duel.AnnounceCard(tp,TYPE_MONSTER,OPCODE_ISTYPE)
		local e3=Effect.CreateEffect(e:GetHandler())
		e3:SetType(EFFECT_TYPE_FIELD)
		e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e3:SetCode(EFFECT_CANNOT_ACTIVATE)
		e3:SetTargetRange(0,1)
		e3:SetValue(function(_e,_re,_tp) return _re:GetHandler():IsCode(ac3) and _re:IsMonsterEffect() and _re:GetActivateLocation()==LOCATION_MZONE end)
		e3:SetReset(RESET_PHASE+PHASE_END)
		Duel.RegisterEffect(e3,tp)
	end
end

--effect 2
function s.con2filter(c)
	return c:IsMonster()
end

function s.con2(e,tp,eg,ep,ev,re,r,rp)
	return eg:FilterCount(s.con2filter,nil)>0
end

function s.tg2filter(c,e,tp)
	return c:IsMonster() and c:IsCanBeEffectTarget(e) and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and ((c:IsSetCard(0xf34) and not c:IsType(TYPE_FUSION)) or c:IsControler(1-tp))
end

function s.tg2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and s.tg2filter(chkc,e,tp) end
	local g=Duel.GetMatchingGroup(s.tg2filter,tp,LOCATION_GRAVE,LOCATION_GRAVE,nil,e,tp)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and #g>0 end
	local sg=aux.SelectUnselectGroup(g,e,tp,1,1,aux.TRUE,1,tp,HINTMSG_SPSUMMON)
	Duel.SetTargetCard(sg)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,sg,1,0,0)
end

function s.op2(e,tp,eg,ep,ev,re,r,rp)
	local tg=Duel.GetTargetCards(e):GetFirst()
	if tg then
		Duel.SpecialSummon(tg,0,tp,tp,false,false,POS_FACEUP)
	end
end
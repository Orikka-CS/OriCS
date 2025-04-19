--퍼펙트 산수교실
local s,id=GetID()
function s.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CANNOT_NEGATE+EFFECT_FLAG_CANNOT_INACTIVATE)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_FZONE)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CANNOT_NEGATE+EFFECT_FLAG_CANNOT_INACTIVATE)
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_SPECIAL_SUMMON)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCountLimit(1)
	e2:SetTarget(s.tar2)
	e2:SetOperation(s.op2)
	c:RegisterEffect(e2)
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_FZONE)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CANNOT_NEGATE+EFFECT_FLAG_CANNOT_INACTIVATE)
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCountLimit(1)
	e3:SetTarget(s.tar3)
	e3:SetOperation(s.op3)
	c:RegisterEffect(e3)
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetCode(EFFECT_SYNCHRO_MATERIAL_CUSTOM)
	e4:SetRange(LOCATION_FZONE)
	e4:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CANNOT_NEGATE+EFFECT_FLAG_CANNOT_INACTIVATE)
	e4:SetTargetRange(0xff,0xff)
	e4:SetOperation(s.op4)
	c:RegisterEffect(e4)
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_FIELD)
	e5:SetCode(EFFECT_XYZ_LEVEL)
	e5:SetRange(LOCATION_FZONE)
	e5:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CANNOT_NEGATE+EFFECT_FLAG_CANNOT_INACTIVATE+EFFECT_FLAG_IGNORE_IMMUNE)
	e5:SetTargetRange(0xff,0xff)
	e5:SetCondition(s.con5)
	e5:SetValue(s.val5)
	c:RegisterEffect(e5)
	local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_FIELD)
	e6:SetCode(EFFECT_CANNOT_BE_XYZ_MATERIAL)
	e6:SetRange(LOCATION_FZONE)
	e6:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CANNOT_NEGATE+EFFECT_FLAG_CANNOT_INACTIVATE+EFFECT_FLAG_IGNORE_IMMUNE)
	e6:SetTargetRange(0xff,0xff)
	e6:SetCondition(s.con5)
	e6:SetValue(s.val6)
	c:RegisterEffect(e6)
	local e7=e6:Clone()
	e7:SetCode(EFFECT_CANNOT_BE_SYNCHRO_MATERIAL)
	e7:SetCondition(s.con5)
	e7:SetValue(s.val7)
	c:RegisterEffect(e7)
	local e8=Effect.CreateEffect(c)
	e8:SetType(EFFECT_TYPE_SINGLE)
	e8:SetCode(EFFECT_CANNOT_DISABLE)
	e8:SetRange(LOCATION_FZONE)
	e8:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_IMMEDIATELY_APPLY)
	c:RegisterEffect(e8)
	local e9=Effect.CreateEffect(c)
	e9:SetType(EFFECT_TYPE_FIELD)
	e9:SetCode(EFFECT_SYNCHRO_LEVEL)
	e9:SetRange(LOCATION_FZONE)
	e9:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CANNOT_NEGATE+EFFECT_FLAG_CANNOT_INACTIVATE+EFFECT_FLAG_IGNORE_IMMUNE)
	e9:SetTargetRange(0xff,0xff)
	e9:SetCondition(s.con5)
	e9:SetTarget(s.tar9)
	e9:SetValue(999)
	c:RegisterEffect(e9)
end
s.listed_names={199900000,199900001}
function s.tfil2(c,e,tp)
	return c:IsCode(199900000) and (c:IsAbleToHand()
		or (Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false)))
end
function s.tar2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsExistingMatchingCard(s.tfil2,tp,LOCATION_DECK+LOCATION_GRAVE,LOCATION_GRAVE,1,nil,e,tp)
	end
	Duel.SetPossibleOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
	Duel.SetPossibleOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end
function s.op2(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.tfil2),tp,LOCATION_DECK+LOCATION_GRAVE,LOCATION_GRAVE,1,1,nil,e,tp)
	local tc=g:GetFirst()
	if not tc then
		return
	end
	aux.ToHandOrElse(tc,tp,
		function(c)
			return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		end,
		function(c)
			Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
		end,
		aux.Stringid(id,2)
	)
end
function s.tfil31(c,tp)
	return c:IsCode(199900001) and (c:IsFaceup() or c:IsControler(tp))
end
function s.tfil32(c,g1,g2,g3,ec)
	local sc=g3:GetFirst()
	local eset={}
	while sc do
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SYNCHRO_MATERIAL)
		e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
		sc:RegisterEffect(e1)
		table.insert(eset,e1)
		sc=g3:GetNext()
	end
	local res=false
	local tc=g1:GetFirst()
	while tc do
		if c:IsSynchroSummonable(tc,g3) then
			res=true
			break
		end
		tc=g1:GetNext()
	end
	for i=1,#eset do
		local te=eset[i]
		te:Reset()
	end
	if res then
		return true
	end
	return c:IsSynchroSummonable(nil,g2) or c:IsXyzSummonable(nil,g2)
end
function s.tar3(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local g1=Duel.GetMatchingGroup(s.tfil31,tp,LOCATION_MZONE,LOCATION_MZONE,nil,tp)
	local g2=Duel.GetMatchingGroup(Card.IsType,tp,LOCATION_HAND+LOCATION_MZONE,0,nil,TYPE_MONSTER)
	local g3=Duel.GetMatchingGroup(Card.IsType,tp,LOCATION_HAND+LOCATION_MZONE,LOCATION_MZONE,nil,TYPE_MONSTER)
	if chk==0 then
		return Duel.IsExistingMatchingCard(s.tfil32,tp,LOCATION_EXTRA,0,1,nil,g1,g2,g3,c)
	end
end
function s.op3(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g1=Duel.GetMatchingGroup(s.tfil31,tp,LOCATION_MZONE,LOCATION_MZONE,nil,tp)
	local g2=Duel.GetMatchingGroup(Card.IsType,tp,LOCATION_HAND+LOCATION_MZONE,0,nil,TYPE_MONSTER)
	local g3=Duel.GetMatchingGroup(Card.IsType,tp,LOCATION_HAND+LOCATION_MZONE,LOCATION_MZONE,nil,TYPE_MONSTER)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local sg=Duel.SelectMatchingCard(tp,s.tfil32,tp,LOCATION_EXTRA,0,1,1,nil,g1,g2,g3,c)
	local tc=sg:GetFirst()
	if tc then
		local g4=Group.CreateGroup()
		local sc=g3:GetFirst()
		local eset={}
		while sc do
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_SYNCHRO_MATERIAL)
			e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
			sc:RegisterEffect(e1)
			table.insert(eset,e1)
			sc=g3:GetNext()
		end
		local cc=g1:GetFirst()
		while cc do
			if tc:IsSynchroSummonable(cc,g3) then
				g4:AddCard(cc)
			end
			cc=g1:GetNext()
		end
		for i=1,#eset do
			local te=eset[i]
			te:Reset()
		end
		if #g4>0 and (not tc:IsSynchroSummonable(nil,g2) or Duel.SelectYesNo(tp,aux.Stringid(id,3))) then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SMATERIAL)
			local mg=g4:Select(tp,1,1,nil)
			local mc=mg:GetFirst()
			local sc=g3:GetFirst()
			local eset={}
			while sc do
				local e1=Effect.CreateEffect(c)
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetCode(EFFECT_SYNCHRO_MATERIAL)
				e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
				sc:RegisterEffect(e1)
				table.insert(eset,e1)
				sc=g3:GetNext()
			end
			local e2=Effect.CreateEffect(tc)
			e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
			e2:SetCode(EVENT_ADJUST)
			e2:SetLabelObject(eset)
			e2:SetCondition(s.ocon32)
			e2:SetOperation(s.oop32)
			Duel.RegisterEffect(e2,tp)
			local e3=Effect.CreateEffect(c)
			e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
			e3:SetCode(EVENT_CHAINING)
			e3:SetLabelObject(eset)
			e3:SetOperation(s.oop32)
			Duel.RegisterEffect(e3,tp)
			local e4=e3:Clone()
			e4:SetCode(EVENT_CHAIN_SOLVING)
			Duel.RegisterEffect(e4,tp)
			Duel.SynchroSummon(tp,tc,mc,g3)
		elseif tc:IsSynchroSummonable(nil,g2) then
			Duel.SynchroSummon(tp,tc,nil,g2)
		elseif tc:IsXyzSummonable(nil,g2) then
			Duel.XyzSummon(tp,tc,nil,g2,1,99)
		end
	end
end
function s.ocon32(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return not c:IsLocation(LOCATION_EXTRA)
end
function s.oop32(e,tp,eg,ep,ev,re,r,rp)
	local eset=e:GetLabelObject()
	for i=1,#eset do
		local te=eset[i]
		te:Reset()
	end
	e:Reset()
end
function s.ofil4(c)
	return c:IsFaceup() and c:IsCode(199900001)
end
function s.op4(e,tg,ntg,sg,lv,sc,tp)
	local chk=Duel.IsExistingMatchingCard(s.ofil4,0,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil)
	local res=(chk and lv==9)
		or (not chk and sg:CheckWithSumEqual(Card.GetSynchroLevel,lv,#sg,#sg,sc))
	return res,true
end
function s.con5(e)
	return Duel.IsExistingMatchingCard(s.ofil4,0,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil)
end
function s.val5(e,c,rc)
	return 0x90000+c:GetLevel()
end
function s.val6(e,c)
	if not c then
		return false
	end
	return not c:IsRank(9)
end
function s.val7(e,c)
	if not c then
		return false
	end
	return not c:IsLevel(9)
end
function s.tar9(e,c)
	return not c:HasLevel()
end
local cicbsm=Card.IsCanBeSynchroMaterial
function Card.IsCanBeSynchroMaterial(c,sc,...)
	if c:Type()&TYPE_XYZ~=0 and c:IsHasEffect(EFFECT_SYNCHRO_LEVEL) then
		--not fully implemented
		return true
	end
	return cicbsm(c,sc,...)
end
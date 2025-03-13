--대행관리자 아테
local s,id=GetID()
function s.initial_effect(c)
	--equal summon
	--추후 업뎃 --aux.AddEqualProcedure(c,6,3,aux.FilterBoolFunction(Card.IsType,TYPE_EFFECT),aux.FilterBoolFunction(Card.IsType,TYPE_MONSTER),1,99,s.equalchk)
	s.CardType_Equal=true
	s.EqualChart=6
	s.EqualNote=3
	s.custom_type=CUSTOMTYPE_EQUAL
	local e0=Effect.CreateEffect(c)
	e0:SetDescription(aux.Stringid(27182800,0))
	e0:SetType(EFFECT_TYPE_FIELD)
	e0:SetCode(EFFECT_SPSUMMON_PROC)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetRange(LOCATION_EXTRA)
	e0:SetCondition(s.EqualCondition)
	e0:SetTarget(s.EqualTarget)
	e0:SetOperation(s.EqualOperation)
	--추후 업뎃 --e0:SetValue(SUMMON_TYPE_EQUAL)
	c:RegisterEffect(e0)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_ADJUST)
	e1:SetOperation(aux.EqualChartAndNoteOperation)
	Duel.RegisterEffect(e1,0)
	c:SetStatus(STATUS_NO_LEVEL,true)
	c:EnableReviveLimit()
	--이 카드의 효과를 발동할 때마다, 이 카드의 노트는 3개 올라간다.
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(function(e,tp,eg,ep,ev,re,r,rp) return re:GetHandler() == e:GetHandler() end)
	e2:SetOperation(function(e) e:GetHandler():RegisterFlagEffect(id,RESET_EVENT|RESETS_STANDARD|RESET_CHAIN&~RESET_TURN_SET,0,1) end)
	c:RegisterEffect(e2)
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e3:SetCode(EVENT_CHAIN_SOLVED)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCondition(function(e,tp,eg,ep,ev,re,r,rp) return re:GetHandler() == e:GetHandler() and e:GetHandler():HasFlagEffect(id) end)
	e3:SetOperation(s.noteop)
	c:RegisterEffect(e3)
	--그 몬스터의 컨트롤을 얻는다.
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,0))
	e4:SetCategory(CATEGORY_CONTROL)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_NO_TURN_RESET)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1)
	e4:SetTarget(s.cttg)
	e4:SetOperation(s.ctop)
	c:RegisterEffect(e4)
	--패에서 빛 속성 몬스터 1장을 특수 소환한다.
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(id,1))
	e5:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e5:SetType(EFFECT_TYPE_IGNITION)
	e5:SetRange(LOCATION_MZONE)
	e5:SetCountLimit(1)
	--추후 업뎃 --e5:SetCondition(function(e,tp,eg,ep,ev,re,r,rp) return e:GetHandler():IsFinaleState() end)
	e5:SetCondition(function(e,tp,eg,ep,ev,re,r,rp) return e:GetHandler():GetChart()==e:GetHandler():GetNote() end)
	e5:SetTarget(s.sptg)
	e5:SetOperation(s.spop)
	c:RegisterEffect(e5)
	--이 카드가 피날레 상태일 경우, 이 카드는 창조신족이 된다.
	local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_SINGLE)
	e6:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e6:SetCode(EFFECT_CHANGE_RACE)
	--추후 업뎃 --e6:SetCondition(function(e,tp,eg,ep,ev,re,r,rp) return e:GetHandler():IsFinaleState() end)
	e6:SetCondition(function(e,tp,eg,ep,ev,re,r,rp) return e:GetHandler():GetChart()==e:GetHandler():GetNote() end)
	e6:SetRange(LOCATION_MZONE)
	e6:SetValue(RACE_CREATORGOD)
	c:RegisterEffect(e6)
end
function s.EqualConditionFilter(c,eqc)
	return c:IsFaceup() --and c:IsCanBeEqualMaterial(eqc)
end
function s.EqualCheckGoal(sg,tp,eqc,f1,f2,gf)
	return sg:IsExists(s.EqualCheckChartFilter,1,nil,eqc,f1,f2,gf,sg)
		and Duel.GetLocationCountFromEx(tp,tp,sg,eqc)>0
end
function s.EqualCheckChartFilter(c,eqc,f1,f2,gf,sg)
	if f1 and not f1(c) then
		return false
	end
	if c:GetLevel()~=eqc:GetChart() then
		return false
	end
	local ng=sg:Clone()
	ng:Sub(c)
	if #ng==0 then
		return eqc:GetNote()==0 and (not gf or gf(sg,Group.CreateGroup()))
	end
	local f=f2 or aux.TRUE
	return ng:GetSum(Card.GetLevel)==eqc:GetNote() and ng:FilterCount(f,nil)==#ng and (not gf or gf(Group.CreateGroup(c),ng))
		and ng:IsExists(Card.IsAttribute,1,nil,ATTRIBUTE_LIGHT)
end
function s.EqualCondition(e,c)
	if c==nil then
		return true
	end
	if c:IsType(TYPE_PENDULUM) and c:IsFaceup() then
		return false
	end
	local tp=c:GetControler()
	local mg=Duel.GetMatchingGroup(s.EqualConditionFilter,tp,LOCATION_MZONE,0,nil,c)
	local fg=Auxiliary.GetMustMaterialGroup(tp,EFFECT_MUST_BE_EQUAL_MATERIAL)
	if fg:IsExists(Auxiliary.MustMaterialCounterFilter,1,nil,mg) then
		return false
	end
	Duel.SetSelectedCard(fg)
	return mg:CheckSubGroup(s.EqualCheckGoal,1+1,1+99,tp,c,aux.FilterBoolFunction(Card.IsType,TYPE_EFFECT),aux.FilterBoolFunction(Card.IsType,TYPE_MONSTER),nil)
end
function s.EqualTarget(e,tp,eg,ep,ev,re,r,rp,chk,c)
	local mg=Duel.GetMatchingGroup(s.EqualConditionFilter,tp,LOCATION_MZONE,0,nil,c)
	local fg=Auxiliary.GetMustMaterialGroup(tp,EFFECT_MUST_BE_EQUAL_MATERIAL)
	Duel.SetSelectedCard(fg)
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(27182800,1))
	local cancel=Duel.IsSummonCancelable()
	local sg=mg:SelectSubGroup(tp,s.EqualCheckGoal,cancel,1+1,1+99,tp,c,aux.FilterBoolFunction(Card.IsType,TYPE_EFFECT),aux.FilterBoolFunction(Card.IsType,TYPE_MONSTER),nil)
	if sg then
		sg:KeepAlive()
		e:SetLabelObject(sg)
		return true
	else
		return false
	end
end
function s.EqualOperation(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	c:SetMaterial(g)
	Duel.SendtoGrave(g,REASON_MATERIAL)
	local tc=g:GetFirst()
		while tc do
			Duel.RaiseSingleEvent(tc,EVENT_BE_CUSTOM_MATERIAL,e,CUSTOMREASON_EQUAL,tp,tp,0)
			tc=g:GetNext()
		end
	Duel.RaiseEvent(g,EVENT_BE_CUSTOM_MATERIAL,e,CUSTOMREASON_EQUAL,tp,tp,0)
	g:DeleteGroup()
end
function s.noteop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local val=3
	if val+c:GetNote()>=c:GetChart() then
		val=c:GetChart()-c:GetNote()
	end
	if val<=0 then return false end --추후 업뎃
	Duel.Hint(HINT_CARD,0,id)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_UPDATE_NOTE)
	e1:SetValue(val)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	c:RegisterEffect(e1)
end
function s.ctfilter(c)
	return c:IsType(TYPE_EFFECT) and c:IsControlerCanBeChanged()
end
function s.cttg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and s.ctfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.ctfilter,tp,0,LOCATION_MZONE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)
	local g=Duel.SelectTarget(tp,s.ctfilter,tp,0,LOCATION_MZONE,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_CONTROL,g,1,0,0)
end
function s.ctop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		Duel.GetControl(tc,tp)
	end
end
function s.spfilter(c,e,tp)
	return c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if #g>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
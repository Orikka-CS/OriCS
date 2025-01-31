--�������� "����"
local EFFECT_DOUBLE_XYZ_MATERIAL=511001225 --to be removed when the procedure is updated
local s,id=GetID()
function s.initial_effect(c)
	--�ڽ��� �� / �������� ���� 4 ������ "��������" ���� 1���� Ư�� ��ȯ�Ѵ�.
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCondition(function(e) return not e:GetHandler():IsReason(REASON_RULE) end)
	e1:SetCost(aux.SelfRevealCost)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	--���� 3�� �̻��� ����� �ϴ� �������� ������ ���͸� ������ ��ȯ�� ���, �� ī��� 2�常ŭ�� ������ ����� �� �� �ִ�.
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_DOUBLE_XYZ_MATERIAL)
	e2:SetValue(1)
	e2:SetCondition(function(e) return not Duel.HasFlagEffect(e:GetHandlerPlayer(),id) end)
	e2:SetOperation(function(e,c,matg) return c:IsRace(RACE_SPELLCASTER) and c.minxyzct and c.minxyzct>=3 and matg:FilterCount(s.serenadehoptfilter,nil)<2 end)
	c:RegisterEffect(e2)
	--HOPT workaround for having already used the double material effect earlier in that turn
	aux.GlobalCheck(s,function()
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD)
		ge1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_SET_AVAILABLE+EFFECT_FLAG_IGNORE_RANGE)
		ge1:SetCode(EFFECT_MATERIAL_CHECK)
		ge1:SetValue(s.valcheck)
		Duel.RegisterEffect(ge1,0)
	end)
end
s.listed_series={0xc22}
function s.spfilter(c,e,tp)
	return c:IsSetCard(0xc22) and c:IsLevelBelow(4) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND|LOCATION_GRAVE,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND|LOCATION_GRAVE)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,LOCATION_HAND|LOCATION_GRAVE,0,1,1,nil,e,tp)
	if #g>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
function s.serenadehoptfilter(c)
	return c:IsCode(id) and c:IsHasEffect(EFFECT_DOUBLE_XYZ_MATERIAL)
end
function s.valcheck(e,c)
	if not (c:IsType(TYPE_XYZ) and c:IsRace(RACE_SPELLCASTER) and c.minxyzct and c.minxyzct>=3) then return end
	local g=c:GetMaterial()
	if #g<c.minxyzct and g:IsExists(s.serenadehoptfilter,1,nil) then
		Duel.RegisterFlagEffect(c:GetControler(),id,RESET_PHASE|PHASE_END,0,1)
	end
end
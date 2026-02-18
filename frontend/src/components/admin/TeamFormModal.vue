<script setup lang="ts">
import { ref, watch } from 'vue'
import { type Team } from '@/api/apiTeams'
import ResponsiveModal from '@/components/ui/modal/ResponsiveModal.vue'
import Button from '@/components/ui/button/Button.vue'
import Input from '@/components/ui/input/Input.vue'
import Label from '@/components/ui/label/Label.vue'

interface Props {
  open: boolean
  team: Team | null
}

const props = defineProps<Props>()

const emit = defineEmits<{
  'update:open': [value: boolean]
  save: [data: { name: string; description: string }]
}>()

const name = ref('')
const description = ref('')
const nameError = ref('')

watch(
  () => props.open,
  (isOpen) => {
    if (isOpen) {
      name.value = props.team?.name ?? ''
      description.value = props.team?.description ?? ''
      nameError.value = ''
    }
  },
)

function validateForm(): boolean {
  nameError.value = ''

  if (!name.value.trim()) {
    nameError.value = 'Team name is required'
    return false
  }

  return true
}

function handleSave() {
  if (!validateForm()) return

  emit('save', {
    name: name.value.trim(),
    description: description.value.trim(),
  })
}
</script>

<template>
  <ResponsiveModal
    :open="open"
    :title="team ? 'Edit Team' : 'Create Team'"
    @update:open="emit('update:open', $event)"
  >
    <form class="space-y-4" @submit.prevent="handleSave">
      <div class="space-y-2">
        <Label for="team-name">Team Name</Label>
        <Input
          id="team-name"
          v-model="name"
          placeholder="Enter team name"
          class="w-full"
          :class="{ 'border-destructive': nameError }"
        />
        <p v-if="nameError" class="text-sm text-destructive">
          {{ nameError }}
        </p>
      </div>

      <div class="space-y-2">
        <Label for="team-description">Description</Label>
        <Input
          id="team-description"
          v-model="description"
          placeholder="Enter description (optional)"
          class="w-full"
        />
      </div>

      <div class="flex gap-3 pt-2">
        <Button
          type="button"
          variant="outline"
          class="flex-1 min-h-touch"
          @click="emit('update:open', false)"
        >
          Cancel
        </Button>
        <Button
          type="submit"
          class="flex-1 min-h-touch"
        >
          {{ team ? 'Save Changes' : 'Create Team' }}
        </Button>
      </div>
    </form>
  </ResponsiveModal>
</template>

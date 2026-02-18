<script setup lang="ts">
import type { HTMLAttributes } from 'vue'
import { computed } from 'vue'
import { useVModel } from '@vueuse/core'
import { cn } from '@/lib/utils'

const props = defineProps<{
  id: string
  label: string
  type?: string
  defaultValue?: string | number
  modelValue?: string | number
  error?: string
  class?: HTMLAttributes['class']
}>()

const emits = defineEmits<{
  'update:modelValue': [payload: string | number]
}>()

const modelValue = useVModel(props, 'modelValue', emits, {
  passive: true,
  defaultValue: props.defaultValue,
})

const hasValue = computed(() => modelValue.value !== undefined && modelValue.value !== '')
</script>

<template>
  <div :class="cn('relative w-full', props.class)">
    <input
      :id="id"
      v-model="modelValue"
      :type="type ?? 'text'"
      placeholder=" "
      :class="cn(
        'peer w-full h-12 px-4 pt-5 pb-1.5 rounded-lg border bg-transparent text-sm transition-all duration-base',
        'focus:outline-none focus:ring-2 focus:ring-ring focus:border-transparent',
        'placeholder-shown:pt-3.5',
        error ? 'border-danger ring-danger/20' : 'border-input',
        'min-h-touch'
      )"
      :aria-invalid="!!error"
      :aria-describedby="error ? `${id}-error` : undefined"
    />
    <label
      :for="id"
      :class="cn(
        'absolute left-4 transition-all duration-fast pointer-events-none',
        'text-muted-foreground',
        hasValue || 'peer-focus:'
          ? 'top-1.5 text-xs font-medium'
          : 'top-3.5 text-sm',
        'peer-focus:top-1.5 peer-focus:text-xs peer-focus:font-medium peer-focus:text-primary',
        'peer-placeholder-shown:top-3.5 peer-placeholder-shown:text-sm peer-placeholder-shown:font-normal'
      )"
    >
      {{ label }}
    </label>
    <p
      v-if="error"
      :id="`${id}-error`"
      class="mt-1 text-xs text-danger"
      role="alert"
    >
      {{ error }}
    </p>
  </div>
</template>

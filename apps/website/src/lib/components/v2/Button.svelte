<script generics="T extends 'button' | 'submit' | 'link' = 'button'" lang="ts">
  import { RingSpinner } from '$lib/components/spinners';
  import { getFormContext } from '$lib/form';
  import { css, cva } from '$styled-system/css';
  import { center } from '$styled-system/patterns';
  import type { HTMLAnchorAttributes, HTMLButtonAttributes } from 'svelte/elements';
  import type { RecipeVariant, RecipeVariantProps } from '$styled-system/css';
  import type { SystemStyleObject } from '$styled-system/types';

  type $$Props = RecipeVariantProps<typeof recipe> & {
    type?: T;
    loading?: boolean;
    style?: SystemStyleObject;
    disabled?: boolean;
  } & Omit<
      T extends 'link'
        ? HTMLAnchorAttributes & { external?: boolean }
        : Omit<HTMLButtonAttributes, 'type' | 'disabled'>,
      'class' | 'style'
    >;

  type $$Events = T extends 'link' ? unknown : { click: MouseEvent };

  export let type: 'button' | 'submit' | 'link' = 'button';

  export let style: SystemStyleObject | undefined;

  export let disabled = false;
  export let loading = false;
  export let variant: Variants['variant'] = 'gray-primary-fill';
  export let size: Variants['size'] = 'md';

  export let external = false;

  $: element = type === 'link' ? 'a' : 'button';

  const { isSubmitting } = getFormContext().form ?? {};

  $: showSpinner = !!(loading || (type === 'submit' && $isSubmitting));
  $: props = type === 'link' ? ({ 'aria-disabled': disabled ? 'true' : 'false' } as const) : { type, disabled };

  type Variants = RecipeVariant<typeof recipe>;
  const recipe = cva({
    base: {
      textAlign: 'center',
      outlineOffset: '0',
      userSelect: 'none',
      color: { _enabled: 'gray.5', _disabled: 'gray.400' },
      backgroundColor: { _disabled: 'gray.150' },
      pointerEvents: { _disabled: 'none', _busy: 'none' },
    },
    variants: {
      variant: {
        'gray-primary-fill': {
          _enabled: {
            backgroundColor: {
              base: 'gray.900',
              _hover: 'gray.800',
              _focusVisible: 'gray.800',
              _active: 'gray.900',
              _pressed: 'gray.900',
            },
            outlineWidth: { _active: '2px', _pressed: '2px' },
            outlineColor: { _active: 'gray.400', _pressed: 'gray.400' },
          },
        },
        'gray-sub-fill': {
          _enabled: {
            color: 'gray.900',
            backgroundColor: {
              base: 'gray.50',
              _hover: 'gray.100',
              _focusVisible: 'gray.100',
              _active: 'gray.50',
              _pressed: 'gray.50',
            },
            outlineWidth: { _active: '2px', _pressed: '2px' },
            outlineColor: { _active: 'gray.200', _pressed: 'gray.200' },
          },
        },
        'brand-fill': {
          _enabled: {
            backgroundColor: {
              base: 'brand.400',
              _hover: 'brand.600',
              _focusVisible: 'brand.600',
              _active: 'brand.400',
              _pressed: 'brand.400',
            },
            outlineWidth: { _active: '2px', _pressed: '2px' },

            outlineColor: { _active: 'brand.600', _pressed: 'brand.600' },
          },
        },
        'gradation-fill': {
          _enabled: {
            bgGradient: 'to-r',
            gradientFrom: {
              base: '[#B597F6]',
              _hover: '[#9679D6]',
              _focusVisible: '[#9679D6]',
              _active: '[#B597F6]',
              _pressed: '[#B597F6]',
            },
            gradientTo: {
              base: '[#8364E8]',
              _hover: '[#6345C3]',
              _focusVisible: '[#6345C3]',
              _active: '[#8364E8]',
              _pressed: '[#8364E8]',
            },
            outlineWidth: { _active: '2px', _pressed: '2px' },
            outlineColor: { _active: 'brand.400', _pressed: 'brand.400' },
          },
        },
        'gray-outline': {
          _enabled: {
            color: 'gray.900',
            backgroundColor: { _hover: 'gray.100', _focusVisible: 'gray.100', _active: 'gray.5', _pressed: 'gray.5' },
            outlineWidth: { base: '1px', _active: '3px', _pressed: '3px' },
            outlineColor: 'gray.200',
          },
        },
        'gray-text': {
          _enabled: {
            color: 'gray.900',
            backgroundColor: { _hover: 'gray.50', _focusVisible: 'gray.50', _active: 'gray.5', _pressed: 'gray.5' },
            outlineWidth: { base: '1px', _active: '2px', _pressed: '2px' },
            outlineColor: 'gray.200',
          },
        },
        'red-outline': {
          _enabled: {
            color: 'red.600',
            backgroundColor: { _hover: 'red.50', _focusVisible: 'red.50', _active: 'gray.5', _pressed: 'gray.5' },
            outlineWidth: { base: '1px', _active: '3px', _pressed: '3px' },
            outlineColor: 'red.600',
          },
        },
        'red-fill': {
          _enabled: {
            backgroundColor: {
              base: 'red.600',
              _active: 'red.600',
              _hover: 'red.800',
              _focusVisible: 'red.600',
              _pressed: 'red.600',
            },
            outlineWidth: { _active: '2px', _pressed: '2px' },
            outlineColor: { _active: 'red.900', _pressed: 'red.900' },
          },
        },
      },
      size: {
        xs: { paddingX: '8px', paddingY: '4px', fontSize: '12px', fontWeight: 'medium' },
        sm: { paddingX: '12px', paddingY: '9px', fontSize: '13px', fontWeight: 'medium' },
        md: { padding: '12px', fontSize: '14px', fontWeight: 'semibold' },
        lg: { paddingX: '16px', paddingY: '14px', fontSize: '14px', fontWeight: 'semibold' },
      },
    },
  });
</script>

<svelte:element
  this={element}
  class={css(recipe.raw({ variant, size }), showSpinner && { position: 'relative' }, style)}
  aria-busy={showSpinner}
  role="button"
  tabindex="0"
  on:click
  {...$$restProps}
  {...props}
  {...external && {
    target: '_blank',
    rel: 'noopener noreferrer',
  }}
>
  {#if showSpinner}
    <div class={center({ position: 'absolute', inset: '0', padding: '[inherit]' })}>
      <RingSpinner style={css.raw({ height: 'full', color: variant === 'brand-fill' ? 'gray.150' : 'gray.400' })} />
    </div>
  {/if}
  <div class={css({ display: 'contents' }, showSpinner && { visibility: 'hidden' })}>
    <slot />
  </div>
</svelte:element>
